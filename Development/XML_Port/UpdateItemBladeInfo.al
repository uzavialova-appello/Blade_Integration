xmlport 65001 "Update Item Blade Info"
{
    CaptionML = ENU = 'Update Item Blade Info', ENG = 'Update Item Blade Info';
    //Direction = Import;
    Format = VariableText;
    FieldDelimiter = '';
    FieldSeparator = '<TAB>';

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
            {
                //AutoUpdate = true;
                //AutoSave = true;
                SourceTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = CONST(1));
                AutoSave = false;
                textelement(ItemNo)
                {
                }

                textelement(BladeSku)
                {
                }
                textelement(BladeVariationId)
                {

                }
                // trigger OnAfterModifyRecord()
                // var

                // begin
                //     counter += 1;
                //     Item."Sent to Blade" := true;
                //     Item."Blade Status" := Item."Blade Status"::active;
                //     CreateItemBuffer();
                // end;

                trigger OnBeforeInsertRecord()
                var
                    myInt: Integer;
                begin
                    Item.Reset();
                    Item.SetRange("No.", ItemNo);
                    if Item.FindFirst() then begin
                        Item."Blade Sku" := BladeSku;
                        Item."Blade Item ID" := BladeVariationId;
                        Item."Sent to Blade" := true;
                        Item."Blade Status" := Item."Blade Status"::active;
                        if Item.Modify() then
                            counter += 1;
                    end;
                    CreateItemBuffer();
                end;
            }
        }
    }
    trigger OnPreXmlPort()
    begin
        ItemBuffer.Reset();
        ItemBuffer.DeleteAll();
        counter := 0;
    end;


    trigger OnPostXmlPort()
    var

    begin
        MESSAGE('The total number of records modified is %1', counter);
        ItemJournalLine.Reset();
        //ItemJournalLine.SetRange("Journal Template Name", 'ITEM');
        //ItemJournalLine.SetRange("Journal Batch Name", 'DEFAULT');
        //if ItemJournalLine.FindSet() then;
        ItemJournalLine."Journal Template Name" := 'ITEM';
        ItemJournalLine."Journal Batch Name" := 'DEFAULT';
        // //ItemJnlTemplate.Get(ItemJournalLine."Journal Template Name");
        // ItemJnlBatch.Get(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
        // if ItemJnlBatch."No. Series" <> '' then begin
        //     Clear(NoSeriesMgt);
        //     DocumentNo := NoSeriesMgt.TryGetNextNo(ItemJnlBatch."No. Series", WorkDate());
        // end;
        //
        GetBulkItemStock(ItemJournalLine);
    end;

    procedure GetBulkItemStock(var pItemJournalLine: Record "Item Journal Line")
    var
        lurl: Text;
        TextJsonObject: JsonObject;
        Item: Record Item;
        BladeItemArray: array[10000] of Text;
        TextJsonArray: JsonArray;
        TextJsonObjectValue: JsonValue;
        ltext: Text;
        gcontent: HttpContent;
        gheaders: HttpHeaders;
        responseMsg: HttpResponseMessage;
        lresptext: Text;
        intBladeItemId: Integer;
        JsonToken: JsonToken;
        i: Integer;
        JsonTokentData: JsonToken;
        BladeId: Text;
        BladeInventoryTotal: Text;
        decBladeInventoryTotal: Decimal;
        JsonTokenSaleable: JsonToken;
        JsonTokenMisc: JsonToken;
        ItemJnlTemplate: Record "Item Journal Template";

        ItemJournalLine: Record "Item Journal Line";
        Window: Dialog;
        Text000: Label 'Checking the differences #1##########';

        client: HttpClient;
        BladeMgt: Codeunit "Blade Mgt.";
        InventorySetup: Record "Inventory Setup";
        EntryNo: Integer;
        sessiontoken: Text;
    begin
        BladeMgt.Authentication();
        sessiontoken := BladeMgt.GetSessionToken();
        InventorySetup.Get();
        lurl := InventorySetup."Blade Base Url" + '/products/variations/stocks';
        Clear(TextJsonObject);
        Clear(TextJsonObjectValue);
        Clear(TextJsonArray);
        Clear(NoSeriesMgt);
        TextJsonObject.Add('product_variation_id', '');
        ItemJournalLine := pItemJournalLine;
        //ItemJournalLine.LockTable();check
        ItemJnlTemplate.Get(ItemJournalLine."Journal Template Name");
        ItemJnlBatch.Get(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
        ItemJournalLine.Reset();
        ItemJournalLine.SetRange(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Template Name");
        ItemJournalLine.SetRange(ItemJournalLine."Journal Batch Name", pItemJournalLine."Journal Batch Name");
        if ItemJournalLine.FindLast() then
            LastLineNo := ItemJournalLine."Line No."
        else
            LastLineNo := 10000;
        // if ItemJnlBatch."No. Series" <> '' then begin
        //     Clear(NoSeriesMgt);
        //     DocumentNo := NoSeriesMgt.TryGetNextNo(ItemJnlBatch."No. Series", WorkDate());
        // end;
        //DocumentNo := ItemJournalLine."Document No.";
        ItemBuffer.Reset();
        if ItemBuffer.FindFirst() then begin
            repeat
                Evaluate(intBladeItemId, ItemBuffer."Blade Item ID");
                TextJsonObjectValue.SetValue(intBladeItemId);
                TextJsonArray.Add(TextJsonObjectValue);
            until ItemBuffer.Next() = 0;
        end;
        TextJsonObject.Replace('product_variation_id', TextJsonArray);
        TextJsonObject.Add('warehouse_code', 'CHR');
        TextJsonObject.WriteTo(ltext);
        gcontent.WriteFrom(ltext);
        gcontent.ReadAs(ltext);
        EntryNo := BladeMgt.InsertLog(ltext, lurl);
        gcontent.GetHeaders(gheaders);
        gheaders.Remove('Content-Type');
        gheaders.Add('Content-Type', 'application/json');
        gheaders.Remove('Access-Token');
        gheaders.Add('Access-Token', sessiontoken);
        if Client.Put(lurl, gcontent, responseMsg) then begin
            responseMsg.Content.ReadAs(lresptext);
            BladeMgt.ModifyLogwithResponse(lresptext, EntryNo);
            Clear(TextJsonObject);
            Clear(TextJsonArray);
            JsonToken.ReadFrom(lresptext);
            TextJsonObject := JsonToken.AsObject();
            if TextJsonObject.Get('data', JsonToken) then begin
                TextJsonArray := JsonToken.AsArray();
                for i := 0 to TextJsonArray.Count - 1 do begin
                    TextJsonArray.Get(i, JsonTokentData);
                    TextJsonObject := JsonTokentData.AsObject();
                    if TextJsonObject.Get('product_variation_id', JsonTokentData) then
                        JsonTokentData.WriteTo(BladeId);
                    if TextJsonObject.Get('total_saleable', JsonTokenSaleable) then
                        JsonTokenSaleable.WriteTo(BladeInventoryTotal);
                    BladeId := DelChr(BladeId, '=', '"');
                    BladeInventoryTotal := DelChr(BladeInventoryTotal, '=', '"');
                    Evaluate(decBladeInventoryTotal, BladeInventoryTotal);
                    Window.Open(Text000);
                    CompanyInfo.get();
                    Item.Reset();
                    Item.SetCurrentKey("Blade Item ID");
                    Item.SetRange(Item."Blade Item ID", BladeId);
                    Item.SetFilter("Location Filter", CompanyInfo."Location Code");
                    if Item.FindFirst() then begin
                        clear(StockDifference);
                        Item.CalcFields(Item.Inventory);
                        if (decBladeInventoryTotal <> Item.Inventory) then begin
                            StockDifference := decBladeInventoryTotal - Item.Inventory;
                            InsertItemJournal(Item, ItemJournalLine);
                            Window.Update(1, ItemJournalLine."No.");
                        end;
                    end;
                    Window.Close();
                end;
            end;
        end;
    end;

    procedure CreateItemBuffer()
    var
        EntryInBufferExists: Boolean;
    begin
        ItemBuffer.Init();
        ItemBuffer.SetRange("No.", ItemNo);
        EntryInBufferExists := ItemBuffer.FindFirst();

        if not EntryInBufferExists then begin
            ItemBuffer."No." := ItemNo;
            ItemBuffer."Blade Sku" := BladeSku;//Item."Blade Sku";
            ItemBuffer."Blade Item ID" := BladeVariationId;//Item."Blade Item ID";
        end;

        if EntryInBufferExists then
            ItemBuffer.Modify()
        else
            ItemBuffer.Insert();

    end;

    procedure InsertItemJournal(pItem: Record Item;
    var pItemJournalLine: Record "Item Journal Line")
    begin

        pItemJournalLine.Init();
        LastLineNo += 10000;
        pItemJournalLine."Line No." := LastLineNo;
        pItemJournalLine.validate(pItemJournalLine."Posting Date", WorkDate());
        if StockDifference > 0 then
            pItemJournalLine.Validate(pItemJournalLine."Entry Type", pItemJournalLine."Entry Type"::"Positive Adjmt.")
        else
            pItemJournalLine.Validate(pItemJournalLine."Entry Type", pItemJournalLine."Entry Type"::"Negative Adjmt.");
        pItemJournalLine.Validate(pItemJournalLine."Document No.", DocumentNo);
        pItemJournalLine.Validate(pItemJournalLine."Item No.", pItem."No.");
        pItemJournalLine.Validate(pItemJournalLine.Quantity, Abs(StockDifference));
        pItemJournalLine.Validate(pItemJournalLine."Location Code", CompanyInfo."Location Code");
        pItemJournalLine.Insert(true);
    end;

    procedure GetDocumentNo(pDocumentNo: Code[20])
    begin
        DocumentNo := pDocumentNo;
    end;

    var
        Item: Record Item;
        counter: Integer;
        ItemBuffer: Record "Item" temporary;
        ItemJournalLine: Record "Item Journal Line";
        StockDifference: Decimal;
        LastLineNo: Integer;
        CompanyInfo: Record "Company Information";
        DocumentNo: Code[20];
        ItemJnlBatch: Record "Item Journal Batch";
        NoSeriesMgt: Codeunit NoSeriesManagement;
}