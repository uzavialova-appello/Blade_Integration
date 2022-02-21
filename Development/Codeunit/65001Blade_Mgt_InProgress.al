// codeunit 65001 "Blade Mgt."
// {
//     trigger OnRun()
//     begin

//     end;

//     procedure Authentication()
//     var

//         ResponseMessage: HttpResponseMessage;
//         lurl: Text;
//         RequestHeader: HttpHeaders;
//         TextJsonObject: JsonObject;
//         BladeUsername: Text;
//         ltext: Text;
//         gcontent: HttpContent;
//         lresptext: Text;
//         gheaders: HttpHeaders;
//         metatext: array[2] of Text;
//         datatext: array[2] of Text;
//         JsonToken: JsonToken;
//         textjsonobject1: JsonObject;
//         ErrorMsg: Text;
//         ExpiryDateBlade: Text;
//         PosDate: Integer;
//         PosTime: Integer;
//         txtExpiryDate: Text;
//         txtExpiryTime: Text;
//         ExpiryDate: Date;
//         ExpiryTime: Time;
//         client: HttpClient;
//     // confirmmgt:Codeunit "Confirm Management";

//     begin
//         InventorySetup.Get();
//         GLSetup.Get();
//         InventorySetup.TestField("Blade Base Url");
//         InventorySetup.TestField("Blade Login ID");
//         InventorySetup.TestField("Blade Password");
//         InventorySetup.TestField("Blade Organization ID");
//         InventorySetup.TestField("Blade Brand ID ");
//         //InventorySetup.TestField("Blade Brand ID ");
//         lurl := InventorySetup."Blade Base Url" + '/auth/login';
//         //RequestHeader := Client.DefaultRequestHeaders(); removed temp
//         Clear(TextJsonObject);

//         TextJsonObject.Add('username', InventorySetup."Blade Login ID");
//         TextJsonObject.Add('password', InventorySetup."Blade Password");
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         if Client.Post(lurl, gcontent, ResponseMessage) then begin
//             if not ResponseMessage.IsSuccessStatusCode then
//                 Error('%1: %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);
//             ResponseMessage.Content.ReadAs(lresptext);
//             JsonToken.ReadFrom(lresptext);
//             Clear(TextJsonObject);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;

//             sessiontoken := SelectJsonToken(TextJsonObject, '$.data.session_token').AsValue().AsText();
//             ExpiryDateBlade := SelectJsonToken(TextJsonObject, '$.data.expiry').AsValue().AsText();

//             PosDate := StrPos(ExpiryDateBlade, 'T');
//             PosTime := StrPos(ExpiryDateBlade, '.');
//             txtExpiryDate := CopyStr(ExpiryDateBlade, 1, PosDate - 1);
//             txtExpiryTime := CopyStr(ExpiryDateBlade, PosDate + 1, (PosTime - 1 - PosDate));
//             Evaluate(ExpiryDate, txtExpiryDate);
//             Evaluate(ExpiryTime, txtExpiryTime);
//             ExpiryDateTime := CreateDateTime(ExpiryDate, ExpiryTime);
//         end;
//     end;

//     procedure AddItem(var pItem: Record Item)
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         gResponseMsg: HttpResponseMessage;
//         lresptext: text;
//         JsonToken: JsonToken;
//         TextJsonObjectLine: JsonObject;
//         TextJsonArrayLine: JsonArray;
//         TextJsonObjectArrayLine: JsonObject;
//         Duration: Duration;
//         CurrentDuration: Duration;
//         BladeStatus: Text;
//         BladeId: Text;
//         BladeSku: Text;
//         AttributeArray: array[4] of Text;
//         LengthAttribute: Integer;
//         WidthAttribute: Integer;
//         HeightAttribute: Integer;
//         WeightAttribute: Decimal;
//         ErrorMsg: text;
//         BladeItemNo: Code[20];
//         BaseUnitOfMeasure: Code[20];
//         BaseUnitOfMeasureQty: Integer;
//         BladeProductId: Text;
//         client: HttpClient;
//         TariffNumber: Record "Tariff Number";
//         intBladeIdTariffNumber: Integer;
//         Text000: Label 'The Commodity Code %1 has not been sent to Blade yet.Navigate to "Commodity Codes" page and use the function "Send to Blade".';
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/products/variations?expand=*';
//         clear(TextJsonObject);
//         Clear(TextJsonObjectLine);
//         clear(TextJsonObjectArrayLine);
//         CheckItemAttributes(pItem."No.");
//         AttributeArray[1] := ItemAttributeDictionary.Get('length');
//         AttributeArray[2] := ItemAttributeDictionary.Get('width');
//         AttributeArray[3] := ItemAttributeDictionary.Get('height');
//         AttributeArray[4] := ItemAttributeDictionary.Get('weight');
//         Evaluate(LengthAttribute, AttributeArray[1]);
//         Evaluate(WidthAttribute, AttributeArray[2]);
//         Evaluate(HeightAttribute, AttributeArray[3]);
//         Evaluate(WeightAttribute, AttributeArray[4]);
//         pItem.TestField("Country/Region of Origin Code");
//         pItem.TestField(Barcode);
//         pItem.TestField("Tariff No.");
//         BladeItemNo := RemoveRestrictedCharacters(pItem."No.");
//         TariffNumber.Get(pItem."Tariff No.");
//         if TariffNumber."Blade ID" <> '' then
//             Evaluate(intBladeIdTariffNumber, TariffNumber."Blade ID")
//         else
//             Error(Text000, pItem."Tariff No.");

//         TextJsonObject.Add('sku', BladeItemNo);
//         TextJsonObject.Add('name', pItem.Description);
//         TextJsonObject.Add('barcode', pItem.Barcode);
//         TextJsonObject.Add('brand', InventorySetup."Blade Brand ID ");
//         TextJsonObject.Add('channel', InventorySetup."Blade Organization ID");
//         TextJsonObject.Add('new_component', '');
//         TextJsonObjectLine.Add('perishable', false);
//         TextJsonObjectLine.Add('organic', false);
//         TextJsonObjectLine.Add('what_is_it', pItem.Description);
//         TextJsonObjectLine.Add('made_of', 'unknown');
//         TextJsonObjectLine.Add('used_for', 'unknown');
//         TextJsonObjectLine.Add('customs_country_of_origin_country', pItem."Country/Region of Origin Code");
//         TextJsonObjectLine.Add('product_component_customs_code_id', intBladeIdTariffNumber);
//         TextJsonObjectLine.Add('doqs', '');
//         TextJsonObjectArrayLine.Add('length', LengthAttribute);
//         TextJsonObjectArrayLine.Add('width', WidthAttribute);
//         TextJsonObjectArrayLine.Add('height', HeightAttribute);
//         TextJsonObjectArrayLine.Add('weight', WeightAttribute);
//         TextJsonObjectArrayLine.Add('quantity', 1);
//         TextJsonObjectArrayLine.Add('type', 'SINGLE_PRODUCT');
//         TextJsonObjectArrayLine.Add('shippable', true);
//         TextJsonObjectArrayLine.Add('barcode', pItem.Barcode);
//         TextJsonArrayLine.Add(TextJsonObjectArrayLine);
//         TextJsonObjectLine.Replace('doqs', TextJsonArrayLine);
//         TextJsonObject.Replace('new_component', TextJsonObjectLine);
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Post(lurl, gcontent, gResponseMsg) then begin
//             gResponseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             Clear(TextJsonObjectLine);
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeId := SelectJsonToken(TextJsonObject, '$.data.id').AsValue().AsCode();
//                 BladeStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeSku := SelectJsonToken(TextJsonObject, '$.data.sku').AsValue().AsText();
//                 BladeProductId := SelectJsonToken(TextJsonObject, '$.data.product_id').AsValue().AsText();
//                 BladeId := DelChr(BladeId, '=', '"');
//                 BladeStatus := DelChr(BladeStatus, '=', '"');
//                 BladeProductId := DelChr(BladeProductId, '=', '"');
//                 ValidateBladeItemStatus(BladeStatus, pItem);
//                 pItem.Validate("Sent to Blade", true);
//                 pItem.Validate("Blade Item ID", BladeId);
//                 pItem.Validate("Blade Sku", BladeSku);
//                 if pItem.Modify() then
//                     Message('Item No. %1 has been successfully sent.', pItem."No.");
//                 Commit();
//             end;
//             Clear(ErrorMsg);
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure GetBladeItems()
//     var
//         PageNo: Integer;
//     begin
//         if CurrentDateTime > ExpiryDateTime then begin
//             Authentication();
//         end;
//         PageNo := 1;
//         GetBladeItemsByPage(PageNo);
//         PageNo += 1;
//         while PageNo <= NumberOfPages do begin
//             //PageNo += 1;
//             GetBladeItemsByPage(PageNo);
//             PageNo += 1;
//         end;
//     end;

//     procedure GetBladeItemsByPage(var pPageNo: Integer)
//     var
//         lurl: Text;
//         requestMsg: HttpRequestMessage;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         JsonToken: JsonToken;
//         TextJsonObject: JsonObject;
//         TextJsonArray: JsonArray;
//         i: Integer;
//         JsonTokenData: JsonToken;
//         JsonTokenSku: JsonToken;
//         JsonTokenStatus: JsonToken;
//         ItemNo: Text;
//         JsonTokenId: JsonToken;
//         BladeId: Text;
//         Item: Record Item;
//         TextJsonData: JsonObject;
//         BladeStatus: Text;
//         Bladesku: Text;
//         BladeProductId: Text;
//         ChannelId: Text;
//         ErrorMsg: Text;
//         WebServiceFailedErr: Label 'The call to webservice failed.';
//         client: HttpClient;
//         txtNumberOfPages: Text;
//         Window: Dialog;
//         Text000: Label 'Updating the items #1##########';

//     begin
//         InventorySetup.Get();
//         lurl := InventorySetup."Blade Base Url" + '/products/variations' + '?page=' + format(pPageNo);

//         gheaders := Client.DefaultRequestHeaders();
//         gheaders.Remove('Accept');
//         gheaders.Add('Accept', 'application/json');
//         gheaders.Remove('User-Agent');
//         gheaders.Add('User-Agent', 'Java/1.7.0_51');
//         gheaders.TryAddWithoutValidation('Content-Type', 'application/json');
//         gheaders.TryAddWithoutValidation('Access-Token', sessiontoken);
//         requestMsg.SetRequestUri(lurl);
//         requestMsg.Method := 'GET';
//         if not Client.Send(requestMsg, responseMsg) then
//             Error(WebServiceFailedErr);
//         responseMsg.Content.ReadAs(lresptext);
//         //ModifyLogwithResponse(lresptext, EntryNo);//2302
//         if responseMsg.HttpStatusCode() = 500 then
//             Error(responseMsg.ReasonPhrase());
//         JsonToken.ReadFrom(lresptext);
//         TextJsonObject := JsonToken.AsObject();
//         txtNumberOfPages := SelectJsonToken(TextJsonObject, '$.meta.paging.total_pages').AsValue().AsText();
//         txtNumberOfPages := DelChr(txtNumberOfPages, '=', '"');
//         Evaluate(NumberOfPages, txtNumberOfPages);
//         if TextJsonObject.Get('data', JsonToken) then begin
//             TextJsonArray := JsonToken.AsArray();
//             for i := 0 to TextJsonArray.Count - 1 do begin
//                 TextJsonArray.Get(i, JsonTokenData);
//                 TextJsonObject := JsonTokenData.AsObject();
//                 if TextJsonObject.Get('id', JsonTokenData) then
//                     JsonTokenData.WriteTo(BladeId);
//                 if TextJsonObject.Get('sku', JsonTokenSku) then
//                     JsonTokenSku.WriteTo(ItemNo);
//                 if TextJsonObject.Get('status', JsonTokenStatus) then
//                     JsonTokenStatus.WriteTo(BladeStatus);
//                 BladeProductId := SelectJsonToken(TextJsonObject, '$.product.id').AsValue().AsText();
//                 ChannelId := SelectJsonToken(TextJsonObject, '$.product.channel.id').AsValue().AsText();
//                 BladeId := DelChr(BladeId, '=', '"');
//                 ItemNo := DelChr(ItemNo, '=', '"');
//                 BladeStatus := DelChr(BladeStatus, '=', '"');
//                 BladeProductId := DelChr(BladeProductId, '=', '"');
//                 ChannelId := DelChr(ChannelId, '=', '"');
//                 InsertLog(StrSubstNo('Item No. %1,Blade Variation ID %2', ItemNo, BladeId), lurl);
//                 if StrLen(ItemNo) <= MaxStrLen(Item."No.") then begin
//                     if format(InventorySetup."Blade Organization ID") = ChannelId then begin
//                         Window.Open(Text000);
//                         Item.reset();
//                         Item.SetRange("No.", ItemNo);
//                         if Item.FindFirst() then begin
//                             ValidateBladeItemStatus(BladeStatus, Item);
//                             Item.Validate("Sent to Blade", true);
//                             Item.Validate("Blade Item ID", BladeId);
//                             Item.Validate("Blade Sku", ItemNo);
//                             Item.Modify();
//                             Window.Update(1, Item."No.");
//                             Commit();
//                         end;
//                         Window.Close();
//                     end;
//                 end;
//             end;
//             Message('The items have been updated.');
//         end;
//         if TextJsonObject.Get('error', JsonToken) then begin
//             ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//             Error(ErrorMsg);
//         end;
//     end;

//     procedure GetCommodityCodes()
//     var
//         lurl: Text;
//         requestMsg: HttpRequestMessage;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         JsonToken: JsonToken;
//         TextJsonObject: JsonObject;
//         TextJsonArray: JsonArray;
//         i: Integer;
//         JsonTokenData: JsonToken;
//         JsonTokenCode: JsonToken;
//         JsonTokenName: JsonToken;
//         JsonTokenDutyRate: JsonToken;
//         ItemNo: Text;
//         BladeId: Text;
//         TextJsonData: JsonObject;
//         CommodityCode: Text;
//         BladeCommodityName: Text;
//         BladeDutyRate: Text;
//         intBladeDutyRate: Integer;
//         ChannelId: Text;
//         ErrorMsg: Text;
//         WebServiceFailedErr: Label 'The call to webservice failed.';
//         client: HttpClient;
//         TarrifNumber: Record "Tariff Number";
//         counter: Integer;
//     begin
//         Authentication();
//         InventorySetup.Get();
//         lurl := InventorySetup."Blade Base Url" + '/products/customs?expand=*';
//         Clear(counter);
//         gheaders := Client.DefaultRequestHeaders();
//         gheaders.Remove('Accept');
//         gheaders.Add('Accept', 'application/json');
//         gheaders.Remove('User-Agent');
//         gheaders.Add('User-Agent', 'Java/1.7.0_51');
//         gheaders.TryAddWithoutValidation('Content-Type', 'application/json');
//         gheaders.TryAddWithoutValidation('Access-Token', sessiontoken);

//         requestMsg.SetRequestUri(lurl);
//         requestMsg.Method := 'GET';

//         if not Client.Send(requestMsg, responseMsg) then
//             Error(WebServiceFailedErr);
//         responseMsg.Content.ReadAs(lresptext);

//         if responseMsg.HttpStatusCode() = 500 then
//             Error(responseMsg.ReasonPhrase());
//         JsonToken.ReadFrom(lresptext);
//         TextJsonObject := JsonToken.AsObject();
//         if TextJsonObject.Get('data', JsonToken) then begin
//             TextJsonArray := JsonToken.AsArray();
//             for i := 0 to TextJsonArray.Count - 1 do begin
//                 TextJsonArray.Get(i, JsonTokenData);
//                 TextJsonObject := JsonTokenData.AsObject();
//                 if TextJsonObject.Get('id', JsonTokenData) then
//                     JsonTokenData.WriteTo(BladeId);
//                 if TextJsonObject.Get('code', JsonTokenCode) then
//                     JsonTokenCode.WriteTo(CommodityCode);
//                 if TextJsonObject.Get('name', JsonTokenName) then
//                     JsonTokenName.WriteTo(BladeCommodityName);
//                 if TextJsonObject.Get('duty_rate', JsonTokenDutyRate) then
//                     JsonTokenDutyRate.WriteTo(BladeDutyRate);
//                 BladeId := DelChr(BladeId, '=', '"');
//                 CommodityCode := DelChr(CommodityCode, '=', '"');
//                 BladeCommodityName := DelChr(BladeCommodityName, '=', '"');
//                 BladeDutyRate := DelChr(BladeDutyRate, '=', '"');
//                 Evaluate(intBladeDutyRate, BladeDutyRate);
//                 InsertLog(StrSubstNo('Commodity Id %1 and Commodity Code %2', BladeId, CommodityCode), lurl);
//                 TarrifNumber.Reset();
//                 TarrifNumber.Init();
//                 TarrifNumber."No." := CommodityCode;
//                 TarrifNumber.Description := CopyStr(BladeCommodityName, 1, MaxStrLen(TarrifNumber.Description));
//                 TarrifNumber."Blade ID" := BladeId;
//                 TarrifNumber."Duty Rate" := intBladeDutyRate;
//                 if TarrifNumber.Insert() then
//                     counter += 1;
//             end;
//             Message('Total Number of Commodity Codes inserted is %1.', counter);
//         end;
//         if TextJsonObject.Get('error', JsonToken) then begin
//             ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//             Error(ErrorMsg);
//         end;
//     end;

//     procedure CreateCommodityCode(pCommodityCode: Record "Tariff Number")
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         gResponseMsg: HttpResponseMessage;
//         lresptext: text;
//         JsonToken: JsonToken;
//         SendConfirm: Label 'Do you want to send the commodity code %1 to Blade?';
//         BladeId: Text;
//         OrganizationId: Text;
//         ErrorMsg: Text;
//         client: HttpClient;
//     begin
//         if not Confirm(SendConfirm, false, pCommodityCode."No.") then
//             exit;
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/products/customs';
//         clear(TextJsonObject);
//         pCommodityCode.TestField(Description);
//         TextJsonObject.Add('code', pCommodityCode."No.");
//         TextJsonObject.Add('name', pCommodityCode.Description);
//         TextJsonObject.Add('duty_rate', pCommodityCode."Duty Rate");
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Post(lurl, gcontent, gResponseMsg) then begin
//             gResponseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeId := SelectJsonToken(TextJsonObject, '$.data.id').AsValue().AsCode();
//                 OrganizationId := SelectJsonToken(TextJsonObject, '$.data.organisation_id').AsValue().AsCode();
//                 BladeId := DelChr(BladeId, '=', '"');
//                 OrganizationId := delchr(OrganizationId, '=', '"');
//                 pCommodityCode."Blade ID" := BladeId;
//                 if pCommodityCode.Modify() then
//                     Message('Commodity Code %1 has been successfully sent.', pCommodityCode."No.");
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;

//     end;

//     procedure DiscontinueBladeProduct(var pItem: Record Item)
//     var
//         lurl: Text;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: text;
//         client: HttpClient;
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/products/variations/' + pItem."Blade Item ID" + '/discontinue';
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             pItem.Validate("Blade Status", pItem."Blade Status"::discontinued);
//             pItem.Modify();
//         end;
//     end;

//     procedure ActivateBladeProduct(pItem: Record Item)
//     var
//         lurl: Text;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: text;
//         client: HttpClient;
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/products/variations/' + pItem."Blade Item ID" + '/activate';
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             pItem.Validate("Blade Status", pItem."Blade Status"::active);
//             pItem.Modify();
//         end;
//     end;

//     local procedure CheckItemAttributes(ItemNo: Code[20])
//     var
//         ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
//         ItemAttributeValue: Record "Item Attribute Value";
//         ItemAttributeName: array[4] of Text;
//         ItemAttributeNumericValue: array[4] of Text;
//         i: Integer;
//         DefineAttrErr: Label 'The attributes length,width,height and weight are not defined for Item No. %1';
//         DefineAllAttrErr: Label 'Please define all 4 attributes for Item No.';
//         AttrValueNotDefinedErr: Label 'The value needs to be defined for the attribute  %1';
//     begin
//         ItemAttributeValueMapping.Reset();
//         ItemAttributeValueMapping.SetRange("Table ID", 27);
//         ItemAttributeValueMapping.SetRange("No.", ItemNo);
//         if not ItemAttributeValueMapping.FindSet() then
//             Error(DefineAttrErr, ItemNo);
//         if (ItemAttributeValueMapping.Count < 4) then
//             Error(DefineAllAttrErr, ItemNo);
//         clear(ItemAttributeDictionary);
//         repeat
//             ItemAttributeValue.Reset();
//             ItemAttributeValue.get(ItemAttributeValueMapping."Item Attribute ID", ItemAttributeValueMapping."Item Attribute Value ID");
//             ItemAttributeValue.CalcFields("Attribute Name");
//             if (ItemAttributeValue.Value = '') then
//                 Error(AttrValueNotDefinedErr, ItemAttributeValue."Attribute Name");
//             ItemAttributeDictionary.Add(ItemAttributeValue."Attribute Name", ItemAttributeValue.Value);
//         until ItemAttributeValueMapping.Next() = 0;
//     end;

//     procedure RemoveRestrictedCharacters(ItemNo: Code[20]): code[20]
//     var
//         i: Integer;
//         Letter: Text[1];
//         NewItemNo: Code[20];
//     begin
//         NewItemNo := '';
//         Letter := '';
//         for i := 1 to STRLEN(ItemNo) do begin
//             Letter := COPYSTR(ItemNo, i, 1);
//             if not ((Letter = '/') or (Letter = '*') or (Letter = '+')) then
//                 NewItemNo += Letter;
//         end;
//         exit(NewItemNo);
//     end;

//     procedure GetBulkItemStock(var pItemJournalLine: Record "Item Journal Line")
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         Item: Record Item;
//         BladeItemArray: array[10000] of Text;
//         TextJsonArray: JsonArray;
//         TextJsonObjectValue: JsonValue;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         intBladeItemId: Integer;
//         JsonToken: JsonToken;
//         i: Integer;
//         JsonTokentData: JsonToken;
//         BladeId: Text;
//         BladeInventoryTotal: Text;
//         decBladeInventoryTotal: Decimal;
//         JsonTokenSaleable: JsonToken;
//         JsonTokenMisc: JsonToken;
//         ItemJnlTemplate: Record "Item Journal Template";
//         ItemJnlBatch: Record "Item Journal Batch";
//         ItemJournalLine: Record "Item Journal Line";
//         Window: Dialog;
//         Text000: Label 'Checking the differences #1##########';
//         NoSeriesMgt: Codeunit NoSeriesManagement;
//         client: HttpClient;
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/products/variations/stocks';
//         Clear(TextJsonObject);
//         Clear(TextJsonObjectValue);
//         Clear(TextJsonArray);
//         Clear(NoSeriesMgt);
//         TextJsonObject.Add('product_variation_id', '');
//         ItemJournalLine := pItemJournalLine;
//         ItemJournalLine.LockTable();

//         ItemJnlTemplate.Get(ItemJournalLine."Journal Template Name");
//         ItemJnlBatch.Get(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
//         ItemJournalLine.Reset();
//         ItemJournalLine.SetRange(ItemJournalLine."Journal Template Name", pItemJournalLine."Journal Template Name");
//         ItemJournalLine.SetRange(ItemJournalLine."Journal Batch Name", pItemJournalLine."Journal Batch Name");
//         if ItemJournalLine.FindLast() then
//             LastLineNo := ItemJournalLine."Line No."
//         else
//             LastLineNo := 10000;
//         DocumentNo := ItemJournalLine."Document No.";
//         Item.Reset();
//         Item.SetFilter(Item."Blade Item ID", '<>%1', '');
//         Item.SetRange(Item."Sent to Blade", true);
//         Item.SetRange(Item.Blocked, false);
//         if Item.FindFirst() then begin
//             repeat
//                 Evaluate(intBladeItemId, Item."Blade Item ID");
//                 TextJsonObjectValue.SetValue(intBladeItemId);
//                 TextJsonArray.Add(TextJsonObjectValue);
//             until Item.Next() = 0;
//         end;
//         TextJsonObject.Replace('product_variation_id', TextJsonArray);
//         TextJsonObject.Add('warehouse_code', 'CHR');
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             Clear(TextJsonArray);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 TextJsonArray := JsonToken.AsArray();
//                 for i := 0 to TextJsonArray.Count - 1 do begin
//                     TextJsonArray.Get(i, JsonTokentData);
//                     TextJsonObject := JsonTokentData.AsObject();
//                     if TextJsonObject.Get('product_variation_id', JsonTokentData) then
//                         JsonTokentData.WriteTo(BladeId);
//                     if TextJsonObject.Get('total_saleable', JsonTokenSaleable) then
//                         JsonTokenSaleable.WriteTo(BladeInventoryTotal);
//                     BladeId := DelChr(BladeId, '=', '"');
//                     BladeInventoryTotal := DelChr(BladeInventoryTotal, '=', '"');
//                     Evaluate(decBladeInventoryTotal, BladeInventoryTotal);
//                     Window.Open(Text000);
//                     CompanyInfo.get();
//                     Item.Reset();
//                     Item.SetCurrentKey("Blade Item ID");
//                     Item.SetRange(Item."Blade Item ID", BladeId);
//                     Item.SetFilter("Location Filter", CompanyInfo."Location Code");
//                     if Item.FindFirst() then begin
//                         clear(StockDifference);
//                         Item.CalcFields(Item.Inventory);
//                         if (decBladeInventoryTotal <> Item.Inventory) then begin
//                             StockDifference := decBladeInventoryTotal - Item.Inventory;
//                             InsertItemJournal(Item, ItemJournalLine);
//                             Window.Update(1, ItemJournalLine."No.");
//                         end;
//                     end;
//                     Window.Close();
//                 end;
//             end;
//         end;
//     end;

//     local procedure InsertItemJournal(pItem: Record Item; var pItemJournalLine: Record "Item Journal Line")
//     begin
//         pItemJournalLine.Init();
//         LastLineNo += 10000;
//         pItemJournalLine."Line No." := LastLineNo;
//         pItemJournalLine.validate(pItemJournalLine."Posting Date", WorkDate());
//         if StockDifference > 0 then
//             pItemJournalLine.Validate(pItemJournalLine."Entry Type", pItemJournalLine."Entry Type"::"Positive Adjmt.")
//         else
//             pItemJournalLine.Validate(pItemJournalLine."Entry Type", pItemJournalLine."Entry Type"::"Negative Adjmt.");
//         pItemJournalLine.Validate(pItemJournalLine."Document No.", DocumentNo);
//         pItemJournalLine.Validate(pItemJournalLine."Item No.", pItem."No.");
//         pItemJournalLine.Validate(pItemJournalLine.Quantity, Abs(StockDifference));
//         pItemJournalLine.Validate(pItemJournalLine."Location Code", CompanyInfo."Location Code");
//         pItemJournalLine.Insert(true);
//     end;

//     procedure GetBulkPhysicalStock(var pItemJournalLine: Record "Item Journal Line")
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         TextJsonObjectValue: JsonValue;
//         TextJsonArray: JsonArray;
//         ItemJournalLine: Record "Item Journal Line";
//         ItemJnlTemplate: Record "Item Journal Template";
//         ItemJnlBatch: Record "Item Journal Batch";
//         Item: Record Item;
//         intBladeItemId: Integer;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         JsonTokentData: JsonToken;
//         i: Integer;
//         BladeId: Text;
//         BladeInventory: text;
//         decBladeInventory: Decimal;
//         JsonTokenSaleable: JsonToken;
//         Window: Dialog;
//         Text000: Label 'Getting physical stock #1##########';
//         counter: Integer;
//         ErrorMsg: Text;
//         client: HttpClient;
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/products/variations/stocks';
//         Clear(TextJsonObject);
//         Clear(TextJsonObjectValue);
//         Clear(TextJsonArray);
//         Clear(counter);
//         TextJsonObject.Add('product_variation_id', '');
//         ItemJournalLine := pItemJournalLine;
//         ItemJournalLine.LockTable();
//         ItemJnlTemplate.Get(ItemJournalLine."Journal Template Name");
//         ItemJnlBatch.Get(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
//         ItemJournalLine.Reset();
//         ItemJournalLine.SetRange(ItemJournalLine."Journal Template Name", pItemJournalLine."Journal Template Name");
//         ItemJournalLine.SetRange(ItemJournalLine."Journal Batch Name", pItemJournalLine."Journal Batch Name");

//         CompanyInfo.get();
//         Item.Reset();
//         Item.SetCurrentKey("Blade Item ID");
//         Item.SetFilter(Item."Blade Item ID", '<>%1', '');
//         Item.SetFilter(Item."Location Filter", CompanyInfo."Location Code");
//         Item.SetRange(Item."Sent to Blade", true);
//         if Item.FindFirst() then begin
//             repeat
//                 Evaluate(intBladeItemId, Item."Blade Item ID");
//                 TextJsonObjectValue.SetValue(intBladeItemId);
//                 TextJsonArray.Add(TextJsonObjectValue);
//             until Item.Next() = 0;
//         end;
//         TextJsonObject.Replace('product_variation_id', TextJsonArray);
//         TextJsonObject.Add('warehouse_code', 'CHR');
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             Clear(TextJsonArray);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 TextJsonArray := JsonToken.AsArray();
//                 for i := 0 to TextJsonArray.Count - 1 do begin
//                     TextJsonArray.Get(i, JsonTokentData);
//                     TextJsonObject := JsonTokentData.AsObject();
//                     if TextJsonObject.Get('product_variation_id', JsonTokentData) then
//                         JsonTokentData.WriteTo(BladeId);
//                     if TextJsonObject.Get('total_saleable', JsonTokenSaleable) then
//                         JsonTokenSaleable.WriteTo(BladeInventory);
//                     BladeId := DelChr(BladeId, '=', '"');
//                     BladeInventory := DelChr(BladeInventory, '=', '"');
//                     Evaluate(decBladeInventory, BladeInventory);
//                     Window.Open(Text000);
//                     Item.Reset();
//                     Item.SetRange(Item."Blade Item ID", BladeId);
//                     if Item.FindFirst() then;
//                     ItemJournalLine.SetRange(ItemJournalLine."Item No.", Item."No.");
//                     ItemJournalLine.SetRange(ItemJournalLine."Location Code", CompanyInfo."Location Code");
//                     if ItemJournalLine.FindFirst() then begin
//                         if (ItemJournalLine."Qty. (Calculated)" <> decBladeInventory) then begin
//                             ItemJournalLine.validate(ItemJournalLine."Qty. (Phys. Inventory)", decBladeInventory);
//                             Window.Update(1, ItemJournalLine."No.");
//                             if ItemJournalLine.Modify() then
//                                 counter += 1;
//                         end;
//                     end;
//                     Window.Close();
//                 end;
//                 Message('%1 records have been modified.', counter);
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure CreateWhseShipmentOrder(var pWhseShipmentHeader: Record "Warehouse Shipment Header")
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         TextJsonObjectOrder: JsonObject;
//         TextJsonObjectShippingAddress: JsonObject;
//         TextJsonObjectLines: JsonObject;
//         TextJsonObjectLineVariation: JsonObject;
//         TextJsonObjectAttribute: JsonObject;
//         TextJsonObjectShipping: JsonObject;
//         textjsonArrayAttribute: JsonArray;
//         TextJsonArrayLine: JsonArray;
//         TextJsonObjectArrayLine: JsonObject;
//         Customer: Record Customer;
//         WhseShipmentLine: Record "Warehouse Shipment Line";
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         gResponseMsg: HttpResponseMessage;
//         lresptext: text;
//         JsonToken: JsonToken;
//         BladeOrderId: text;
//         BladeOrderStatus: Text;
//         ErrorMsg: Text;
//         TextLinesArrayResp: text;
//         i: Integer;
//         JsonTokenId: JsonToken;
//         JsonTokenStatus: JsonToken;
//         JsonTokenSku: JsonToken;
//         BladeSku: Text;
//         BladeLineId: Text;
//         BladeLineStatus: Text;
//         CountryCode: Code[2];
//         SalesHeader: Record "Sales Header";
//         SalesLine: Record "Sales Line";
//         WhseAmount: Decimal;
//         TotalWhseAmount: Decimal;
//         ItemNo: Code[20];
//         Item: Record Item;
//         NothingToSendErr: Label 'There is nothing to send to Blade';
//         client: HttpClient;
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts?expand=*';
//         clear(TextJsonObject);
//         Clear(TextJsonObjectOrder);
//         clear(TextJsonObjectArrayLine);
//         Clear(TextJsonObjectShippingAddress);
//         Clear(TextJsonObjectLines);
//         Clear(TextJsonObjectLineVariation);
//         Clear(TextJsonObjectAttribute);
//         Clear(TextJsonObjectShipping);
//         Clear(WhseAmount);
//         Clear(TotalWhseAmount);
//         SalesHeader.get(SalesHeader."Document Type"::Order, pWhseShipmentHeader."Sales Order No.");
//         SalesHeader.TestField("Ship-to Address");
//         SalesHeader.TestField("Ship-to City");
//         SalesHeader.TestField("Ship-to Post Code");
//         SalesHeader.TestField("Delivery Instructions");
//         TextJsonObject.Add('warehouse', 'CHR');
//         TextJsonObject.Add('order', '');
//         TextJsonObjectOrder.Add('channel', InventorySetup."Blade Order Channel ID ");
//         TextJsonObjectOrder.Add('reference', pWhseShipmentHeader."Sales Order No." + '_' + pWhseShipmentHeader."No.");
//         TextJsonObjectOrder.Add('currency', GLSetup."LCY Code");
//         TextJsonObject.Replace('order', TextJsonObjectOrder);
//         TextJsonObject.Add('date_placed', Today);
//         TextJsonObject.Add('shipping_address', '');
//         TextJsonObjectShippingAddress.Add('first_name', SalesHeader."Ship-to Name");
//         TextJsonObjectShippingAddress.Add('last_name', SalesHeader."Ship-to Name");
//         TextJsonObjectShippingAddress.Add('address_one', SalesHeader."Ship-to Address");
//         TextJsonObjectShippingAddress.Add('address_two', SalesHeader."Ship-to Address 2");
//         TextJsonObjectShippingAddress.Add('town', SalesHeader."Ship-to City");
//         if (SalesHeader."Ship-to Country/Region Code" <> '') then
//             CountryCode := SalesHeader."Ship-to Country/Region Code"
//         else
//             CountryCode := 'GB';
//         TextJsonObjectShippingAddress.Add('country_id', CountryCode);
//         textJsonObjectShippingAddress.Add('county', SalesHeader."Ship-to County");
//         TextJsonObjectShippingAddress.Add('postcode', SalesHeader."Ship-to Post Code");
//         if SalesHeader."Sell-to E-Mail" <> '' then
//             TextJsonObjectShippingAddress.Add('telephone', SalesHeader."Sell-to E-Mail");
//         TextJsonObject.Replace('shipping_address', TextJsonObjectShippingAddress);
//         TextJsonObject.Add('lines', '');
//         WhseShipmentLine.Reset();
//         WhseShipmentLine.SetRange(WhseShipmentLine."No.", pWhseShipmentHeader."No.");
//         TextJsonObjectLines.Add('variation', '');
//         TextJsonObjectLineVariation.Add('sku', '');
//         TextJsonObjectLineVariation.Add('channel', '');
//         TextJsonObjectLines.Add('net_unit_principal', '');
//         TextJsonObjectLines.Add('principal_tax', '');
//         TextJsonObjectLines.Add('discount', '');
//         TextJsonObjectLines.Add('discount_type', '');
//         TextJsonObjectLines.Add('quantity', '');
//         if not WhseShipmentLine.FindSet() then
//             Error(NothingToSendErr);
//         repeat
//             Clear(ItemNo);
//             Item.Get(WhseShipmentLine."Item No.");
//             if Item."Blade Sku" <> '' then
//                 ItemNo := Item."Blade Sku"
//             else
//                 ItemNo := WhseShipmentLine."Item No.";
//             WhseShipmentLine.Validate("Blade Sku", ItemNo);
//             WhseShipmentLine.Modify();
//             SalesLine.get(SalesLine."Document Type"::Order, WhseShipmentLine."Source No.", WhseShipmentLine."Source Line No.");
//             TextJsonObjectLineVariation.Replace('sku', WhseShipmentLine."Blade Sku");
//             TextJsonObjectLineVariation.Replace('channel', InventorySetup."Blade Organization ID");
//             TextJsonObjectLines.Replace('variation', TextJsonObjectLineVariation);
//             TextJsonObjectLines.Replace('net_unit_principal', SalesLine."Unit Price");
//             TextJsonObjectLines.Replace('principal_tax', 1973);
//             TextJsonObjectLines.Replace('discount', SalesLine."Line Discount %");
//             TextJsonObjectLines.Replace('discount_type', 'percentage');
//             TextJsonObjectLines.Replace('quantity', WhseShipmentLine.Quantity);
//             WhseAmount := (WhseShipmentLine.Quantity * SalesLine."Unit Price") - (WhseShipmentLine.Quantity * SalesLine."Unit Price" * SalesLine."Line Discount %" / 100);
//             TotalWhseAmount += WhseAmount;
//             TextJsonArrayLine.Add(TextJsonObjectLines.Clone());
//         until WhseShipmentLine.Next() = 0;
//         TextJsonObject.Replace('lines', TextJsonArrayLine);
//         TextJsonObject.Add('delivery_instructions', SalesHeader."Delivery Instructions");
//         TextJsonObject.Add('shipping', '');
//         TextJsonObjectShipping.Add('customer_principal', TotalWhseAmount);
//         TextJsonObject.Replace('shipping', TextJsonObjectShipping);
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);

//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Post(lurl, gcontent, gResponseMsg) then begin
//             gResponseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeOrderId := SelectJsonToken(TextJsonObject, '$.data.id').AsValue().AsCode();//blade sales order Id
//                 BladeOrderId := DelChr(BladeOrderId, '=', '"');
//                 BladeOrderStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeOrderStatus := DelChr(BladeOrderStatus, '=', '"');
//                 TextJsonObjectLines := JsonToken.AsObject();//1
//                 if TextJsonObjectLines.Get('lines', JsonToken) then begin
//                     Clear(TextJsonArrayLine);
//                     Clear(TextJsonObjectLineVariation);//textjsonobject
//                     TextJsonArrayLine := JsonToken.AsArray();
//                     TextJsonArrayLine.WriteTo(TextLinesArrayResp);
//                     for i := 0 to TextJsonArrayLine.Count - 1 do begin
//                         TextJsonArrayLine.Get(i, JsonTokenId);
//                         TextJsonObjectLineVariation := JsonTokenId.AsObject();
//                         if TextJsonObjectLineVariation.Get('id', JsonTokenId) then
//                             JsonTokenId.WriteTo(BladeLineId);
//                         if TextJsonObjectLineVariation.Get('transaction_sku', JsonTokenSku) then
//                             JsonTokenSku.WriteTo(BladeSku);
//                         if TextJsonObjectLineVariation.Get('status', JsonTokenStatus) then
//                             JsonTokenStatus.WriteTo(BladeLineStatus);
//                         BladeLineId := DelChr(BladeLineId, '=', '"');
//                         BladeSku := DelChr(BladeSku, '=', '"');
//                         BladeLineStatus := DelChr(BladeLineStatus, '=', '"');
//                         WhseShipmentLine.Reset();
//                         WhseShipmentLine.SetRange(WhseShipmentLine."No.", pWhseShipmentHeader."No.");
//                         WhseShipmentLine.SetRange(WhseShipmentLine."Blade Sku", BladeSku);
//                         if WhseShipmentLine.FindFirst() then begin
//                             WhseShipmentLine.Validate("Blade Line ID", BladeLineId);
//                             WhseShipmentLine.Validate("Sent to Blade", true);
//                             WhseShipmentLine.Validate("Cancel Reason Code", '');
//                             WhseShipmentLine.Validate("Qty. Sent to Blade", WhseShipmentLine.Quantity);
//                             if BladeLineStatus = 'active' then
//                                 WhseShipmentLine.Validate(WhseShipmentLine."Blade Line Status", WhseShipmentLine."Blade Line Status"::active);
//                             if BladeLineStatus = 'void' then
//                                 WhseShipmentLine.Validate(WhseShipmentLine."Blade Line Status", WhseShipmentLine."Blade Line Status"::void);
//                             WhseShipmentLine.Modify();
//                         end;
//                     end;
//                 end;
//                 ValidateBladeWhseShipmentStatus(BladeOrderStatus, pWhseShipmentHeader);
//                 pWhseShipmentHeader.Validate("Reason Code", '');
//                 pWhseShipmentHeader.Validate("Sent to Blade", true);
//                 pWhseShipmentHeader.Validate("Blade ID", BladeOrderId);
//                 if pWhseShipmentHeader.Modify() then
//                     Message('Warehouse Shipment %1 has been succcessfully sent.', pWhseShipmentHeader."No.");
//                 Commit();
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure CreateSalesOrderFromJob(var pJobPlanningLine: Record "Job Planning Line")//(JobNo: Code[20]; JobTaskNo: Code[20]; LineNo: Integer)
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         TextJsonObjectOrder: JsonObject;
//         TextJsonObjectShippingAddress: JsonObject;
//         TextJsonObjectLines: JsonObject;
//         TextJsonObjectLineVariation: JsonObject;
//         TextJsonObjectAttribute: JsonObject;
//         TextJsonObjectShipping: JsonObject;
//         textjsonArrayAttribute: JsonArray;
//         TextJsonArrayLine: JsonArray;
//         TextJsonObjectArrayLine: JsonObject;
//         OldJobPlanningLine: Record "Job Planning Line";
//         Job: Record Job;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         gResponseMsg: HttpResponseMessage;
//         lresptext: text;
//         JsonToken: JsonToken;
//         BladeOrderId: text;
//         BladeOrderStatus: Text;
//         ErrorMsg: Text;
//         TextLinesArrayResp: text;
//         i: Integer;
//         JsonTokenId: JsonToken;
//         JsonTokenStatus: JsonToken;
//         JsonTokenSku: JsonToken;
//         BladeSku: Text;
//         BladeLineId: Text;
//         BladeLineStatus: Text;
//         ItemNo: Code[20];
//         Item: Record Item;
//         BladeReference: Code[20];
//         CountryCode: Code[2];
//         QtyError: Label 'Qty. %1 is greater than total quantity %2. Please review job planning line quantities and try again.';
//         client: HttpClient;
//         Window: Dialog;
//         Text000: Label 'Sending the job planning lines to Blade. #1##########';
//         ShipToAddress: Record "Ship-to Address";
//         ShiptoCodeErr: Label 'Please select Ship-to Code.';
//     begin
//         if CurrentDateTime > ExpiryDateTime then begin
//             Authentication();
//         end;
//         Window.Open(Text000);
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts?expand=*';
//         clear(TextJsonObject);
//         Clear(TextJsonObjectOrder);
//         clear(TextJsonObjectArrayLine);
//         Clear(TextJsonObjectShippingAddress);
//         Clear(TextJsonObjectLines);
//         Clear(TextJsonObjectLineVariation);
//         Clear(TextJsonObjectAttribute);
//         Clear(TextJsonObjectShipping);
//         Clear(CountryCode);
//         OldJobPlanningLine.Copy(pJobPlanningLine);
//         BladeReference := GetNextBladeReferenceJob(OldJobPlanningLine);
//         //if Job.Get(OldJobPlanningLine."Job No.") then begin
//         if not Job.Get(OldJobPlanningLine."Job No.") then;
//         if Job."Ship-to Code" <> '' then begin
//             ShipToAddress.Get(Job."Sell-to Customer No.", Job."Ship-to Code");
//             ShipToAddress.TestField(City);
//             ShipToAddress.TestField("Post Code");
//         end else
//             Error(ShiptoCodeErr);
//         //end;
//         //Job.TestField(Job."Ship-to City");
//         //Job.TestField(Job."Ship-to Post Code");
//         //end;
//         TextJsonObject.Add('warehouse', 'CHR');
//         TextJsonObject.Add('order', '');
//         TextJsonObjectOrder.Add('channel', InventorySetup."Blade Order Channel ID ");
//         TextJsonObjectOrder.Add('reference', BladeReference);
//         TextJsonObjectOrder.Add('currency', GLSetup."LCY Code");
//         TextJsonObject.Replace('order', TextJsonObjectOrder);
//         TextJsonObject.Add('date_placed', Today);
//         TextJsonObject.Add('shipping_address', '');
//         TextJsonObjectShippingAddress.Add('first_name', ShipToAddress.Name);
//         TextJsonObjectShippingAddress.Add('last_name', ShipToAddress.Name);
//         TextJsonObjectShippingAddress.Add('address_one', ShipToAddress.Address);
//         TextJsonObjectShippingAddress.Add('address_two', ShipToAddress."Address 2");
//         TextJsonObjectShippingAddress.Add('town', ShipToAddress.City);
//         if (ShipToAddress."Country/Region Code" <> '') then
//             CountryCode := ShipToAddress."Country/Region Code"
//         else
//             CountryCode := 'GB';
//         TextJsonObjectShippingAddress.Add('country_id', CountryCode);
//         TextJsonObjectShippingAddress.Add('county', ShipToAddress.County);
//         TextJsonObjectShippingAddress.Add('postcode', ShipToAddress."Post Code");
//         //if ShipToAddress."Phone No." <> '' then
//         TextJsonObjectShippingAddress.Add('telephone', ShipToAddress."Phone No.");
//         // TextJsonObjectShippingAddress.Add('first_name', Job."Ship-to Name");
//         // TextJsonObjectShippingAddress.Add('last_name', Job."Ship-to Name");
//         // TextJsonObjectShippingAddress.Add('address_one', job."Ship-to Address");
//         // TextJsonObjectShippingAddress.Add('address_two', Job."Ship-to Address 2");
//         // TextJsonObjectShippingAddress.Add('town', Job."Ship-to City");
//         // if (Job."Ship-to Country Code" <> '') then
//         //     CountryCode := Job."Ship-to Country Code"
//         // else
//         //     CountryCode := 'GB';
//         //TextJsonObjectShippingAddress.Add('country_id', CountryCode);
//         //textJsonObjectShippingAddress.Add('county', Job."Ship-to County");
//         //TextJsonObjectShippingAddress.Add('postcode', Job."Ship-to Post Code");
//         //if Job."Ship-to Phone No." <> '' then
//         //TextJsonObjectShippingAddress.Add('telephone', Job."Ship-to Phone No.");
//         TextJsonObject.Replace('shipping_address', TextJsonObjectShippingAddress);
//         TextJsonObject.Add('lines', '');
//         TextJsonObjectLines.Add('variation', '');
//         TextJsonObjectLineVariation.Add('sku', '');
//         TextJsonObjectLineVariation.Add('channel', '');
//         TextJsonObjectLines.Add('net_unit_principal', '');
//         TextJsonObjectLines.Add('principal_tax', '');
//         TextJsonObjectLines.Add('discount', '');
//         TextJsonObjectLines.Add('discount_type', '');
//         TextJsonObjectLines.Add('quantity', '');
//         if OldJobPlanningLine.FindSet() then begin
//             repeat
//                 OldJobPlanningLine.TestField(OldJobPlanningLine."Qty. to Send to Blade");
//                 if (OldJobPlanningLine."Qty. to Send to Blade" > OldJobPlanningLine.Quantity) then
//                     Error((QtyError), OldJobPlanningLine."Qty. to Send to Blade", OldJobPlanningLine.Quantity);
//                 Clear(ItemNo);
//                 Item.Get(OldJobPlanningLine."No.");
//                 if Item."Blade Sku" <> '' then
//                     ItemNo := Item."Blade Sku"//check here
//                 else
//                     ItemNo := OldJobPlanningLine."No.";
//                 OldJobPlanningLine.Validate("Blade Sku", ItemNo);
//                 OldJobPlanningLine.Modify();
//                 //TextJsonObjectLineVariation.Replace('sku', OldJobPlanningLine."No.");
//                 TextJsonObjectLineVariation.Replace('sku', ItemNo);
//                 TextJsonObjectLineVariation.Replace('channel', InventorySetup."Blade Organization ID");
//                 TextJsonObjectLines.Replace('variation', TextJsonObjectLineVariation);
//                 TextJsonObjectLines.Replace('net_unit_principal', OldJobPlanningLine."Unit Price");//uz
//                 TextJsonObjectLines.Replace('principal_tax', 1973);
//                 TextJsonObjectLines.Replace('discount', 0);
//                 TextJsonObjectLines.Replace('discount_type', 'percentage');
//                 TextJsonObjectLines.Replace('quantity', OldJobPlanningLine."Qty. to Send to Blade");
//                 TextJsonArrayLine.Add(TextJsonObjectLines.Clone());
//             until OldJobPlanningLine.Next() = 0;
//         end;
//         TextJsonObject.Replace('lines', TextJsonArrayLine);
//         TextJsonObject.Add('shipping', '');
//         TextJsonObjectShipping.Add('customer_principal', OldJobPlanningLine."Line Amount (LCY)");
//         TextJsonObject.Replace('shipping', TextJsonObjectShipping);
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Post(lurl, gcontent, gResponseMsg) then begin
//             gResponseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeOrderId := SelectJsonToken(TextJsonObject, '$.data.id').AsValue().AsCode();//blade sales order Id
//                 BladeOrderId := DelChr(BladeOrderId, '=', '"');
//                 BladeOrderStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeOrderStatus := DelChr(BladeOrderStatus, '=', '"');
//                 TextJsonObjectLines := JsonToken.AsObject();//1
//                 if TextJsonObjectLines.Get('lines', JsonToken) then begin
//                     Clear(TextJsonArrayLine);
//                     Clear(TextJsonObjectLineVariation);//textjsonobject
//                     TextJsonArrayLine := JsonToken.AsArray();
//                     TextJsonArrayLine.WriteTo(TextLinesArrayResp);
//                     for i := 0 to TextJsonArrayLine.Count - 1 do begin
//                         TextJsonArrayLine.Get(i, JsonTokenId);
//                         TextJsonObjectLineVariation := JsonTokenId.AsObject();
//                         if TextJsonObjectLineVariation.Get('id', JsonTokenId) then
//                             JsonTokenId.WriteTo(BladeLineId);
//                         if TextJsonObjectLineVariation.Get('transaction_sku', JsonTokenSku) then
//                             JsonTokenSku.WriteTo(BladeSku);
//                         if TextJsonObjectLineVariation.Get('status', JsonTokenStatus) then
//                             JsonTokenStatus.WriteTo(BladeLineStatus);
//                         BladeLineId := DelChr(BladeLineId, '=', '"');
//                         BladeSku := DelChr(BladeSku, '=', '"');
//                         BladeLineStatus := DelChr(BladeLineStatus, '=', '"');

//                         pJobPlanningLine.SetRange("Blade Sku", BladeSku);
//                         pJobPlanningLine.SetFilter("Blade Line ID", '%1', '');
//                         if pJobPlanningLine.FindFirst() then begin
//                             pJobPlanningLine.Validate("Blade Line ID", BladeLineId);
//                             pJobPlanningLine.Validate("Sent to Blade", true);
//                             pJobPlanningLine.Validate("Line Sent to Blade", true);
//                             if BladeLineStatus = 'active' then
//                                 pjobPlanningLine.Validate("Blade Line Status", pJobPlanningLine."Blade Line Status"::active);
//                             if BladeLineStatus = 'void' then
//                                 pJobPlanningLine.Validate(pjobPlanningLine."Blade Line Status", pjobPlanningLine."Blade Line Status"::void);
//                             ValidateBladeJobLineStatus(BladeOrderStatus, pJobPlanningLine);
//                             pJobPlanningLine.Validate("Blade ID", BladeOrderId);
//                             pJobPlanningLine.Validate("Blade Reference", BladeReference);
//                             pJobPlanningLine.Validate("Qty. Sent to Blade", pJobPlanningLine."Qty. to Send to Blade");
//                             Clear(pJobPlanningLine."Qty. to Send to Blade");
//                             Clear(pJobPlanningLine."To Be Sent To Blade");
//                             Clear(pJobPlanningLine."Blade Cancel Reason");
//                             Window.Update(1, BladeSku);
//                             pJobPlanningLine.Modify();
//                         end;
//                     end;
//                     Window.Close();
//                     Message('Job planning lines have been successfully sent under Blade Reference No. %1.', BladeReference);
//                 end;
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure CancelSalesOrderFromJob(var pJobPLanningLine: Record "Job Planning Line")
//     var
//         lurl: Text;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: text;
//         TextJsonObject: JsonObject;
//         JsonToken: JsonToken;
//         BladeStatus: Text;
//         BladeReference: Code[20];
//         ErrorMsg: Text;
//         InputPageReason: Page "Input Blade Cancel Reason";
//         ReasonCode: Text[30];
//         CancelSalesOrderConfirm: Label 'Do you want to cancel all the adjacent lines for the Blade Reference %1?';
//         ReasonCodeErr: Label 'Please specify the reason.';
//         client: HttpClient;
//     begin
//         if not Confirm(CancelSalesOrderConfirm, false, pJobPLanningLine."Blade Reference") then
//             exit;

//         CLEAR(InputPageReason);
//         InputPageReason.RunModal();
//         if InputPageReason.ActionConfirmed() then
//             ReasonCode := InputPageReason.GetBladeCancelReason()
//         else
//             exit;

//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/' + pJobPLanningLine."Blade ID" + '/cancel?expand=*';//check
//         Clear(TextJsonObject);

//         if ReasonCode <> '' then
//             TextJsonObject.Add('reason', ReasonCode)
//         else
//             Error(ReasonCodeErr);
//         BladeReference := pJobPLanningLine."Blade Reference";
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeStatus := DelChr(BladeStatus, '=', '"');
//                 if pJobPLanningLine.FindFirst() then begin
//                     repeat
//                         ValidateBladeJobLineStatus(BladeStatus, pJobPLanningLine);
//                         pJobPLanningLine.Validate(pJobPLanningLine."Blade Cancel Reason", ReasonCode);
//                         pJobPLanningLine.Validate(pJobPLanningLine."Blade Line Status", pJobPLanningLine."Blade Line Status"::void);
//                         pJobPLanningLine.Validate("Qty. to Send to Blade", pJobPLanningLine."Remaining Qty.");
//                         Clear(pJobPLanningLine."Qty. Sent to Blade");
//                         Clear(pJobPLanningLine."Blade ID");
//                         Clear(pJobPLanningLine."Blade Line ID");
//                         Clear(pJobPLanningLine."Blade Reference");
//                         Clear(pJobPLanningLine."Sent to Blade");
//                         Clear(pJobPLanningLine."Line Sent to Blade");
//                         pJobPLanningLine.Modify();
//                     until pJobPLanningLine.Next() = 0;
//                 end;
//                 Message('Job Planning lines with Blade Reference %1 have been succcessfully cancelled.', BladeReference);
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure CancelSalesOrderLineFromJob(var pJobPlanningLine: Record "Job Planning Line")
//     var
//         lurl: Text;
//         ltext: Text;
//         SalesHeader: Record "Sales Header";
//         TextJsonObject: JsonObject;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         BladeLineStatus: Text;
//         ErrorMsg: Text;
//         CancelJobPlanningLineConfirm: Label 'Do you want to cancel the line with Item No. %1 in the Job Reference No. %2?';
//         client: HttpClient;
//     begin
//         if not Confirm(CancelJobPlanningLineConfirm, false, pJobPlanningLine."No.", pJobPlanningLine."Blade Reference") then
//             exit;
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/' + pJobPlanningLine."Blade ID" + '/lines/' + pJobPlanningLine."Blade Line ID" + '/cancel';
//         pJobPlanningLine.TestField("Blade Cancel Reason");
//         TextJsonObject.Add('reason', pJobPlanningLine."Blade Cancel Reason");
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if client.put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeLineStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeLineStatus := DelChr(BladeLineStatus, '=', '"');
//                 if BladeLineStatus = 'active' then
//                     pJobPlanningLine.Validate(pJobPlanningLine."Blade Line Status", pJobPlanningLine."Blade Line Status"::active);
//                 if BladeLineStatus = 'void' then
//                     pJobPlanningLine.Validate(pJobPlanningLine."Blade Line Status", pJobPlanningLine."Blade Line Status"::void);
//                 pJobPlanningLine.Validate("Qty. to Send to Blade", pJobPlanningLine."Remaining Qty.");
//                 pJobPlanningLine.Validate("Blade Status", pJobPlanningLine."Blade Status"::cancelled);
//                 Clear(pJobPlanningLine."Blade ID");
//                 Clear(pJobPlanningLine."Qty. Sent to Blade");
//                 pJobPlanningLine.Validate("Blade Reference", '');//needed?
//                 Clear(pJobPlanningLine."Sent to Blade");
//                 Clear(pJobPlanningLine."Line Sent to Blade");
//                 Clear(pJobPlanningLine."Blade Line ID");
//                 //pJobPlanningLine.Validate("Blade Cancel Reason", '');
//                 if pJobPlanningLine.Modify() then
//                     Message('Job Planing Line has been successfully cancelled.');
//                 if TextJsonObject.Get('error', JsonToken) then begin
//                     ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                     Error(ErrorMsg);
//                 end;
//             end;
//         end;
//     end;


//     local procedure GetNextBladeReferenceJob(pJobPlanningLine: Record "Job Planning Line"): Code[20]
//     var
//         lJobPlanningLine: Record "Job Planning Line";
//         StartRef: Label '_001';
//     begin
//         lJobPlanningLine.Reset();
//         lJobPlanningLine.SetCurrentKey("blade reference");
//         lJobPlanningLine.SetRange(lJobPlanningLine."Job No.", pJobPlanningLine."Job No.");
//         lJobPlanningLine.SetFilter(lJobPlanningLine."Blade Reference", '<>%1', '');
//         if lJobPlanningLine.FindLast() then
//             exit(IncStr(lJobPlanningLine."Blade Reference"));
//         exit(pJobPlanningLine."Job No." + StartRef);
//     end;

//     local procedure GetNextBladeReferenceWhseReceipt(pWhseReceiptHeader: Record "Warehouse Receipt Header"): Code[20]
//     var
//         lWhseReceiptHeader: Record "Warehouse Receipt Header";
//         StartRef: Label 'Ref_001';
//     begin
//         lWhseReceiptHeader.reset();
//         lWhseReceiptHeader.SetCurrentKey("Blade Reference");
//         lWhseReceiptHeader.SetRange(lWhseReceiptHeader."No.", pWhseReceiptHeader."No.");
//         lWhseReceiptHeader.SetFilter(lWhseReceiptHeader."Blade Reference", '<>%1', '');
//         if lWhseReceiptHeader.FindFirst() then
//             exit(IncStr(lWhseReceiptHeader."Blade Reference"));
//         exit(StartRef);


//     end;

//     procedure CancelWhseShipmentOrder(var pWhseShipmentHeader: Record "Warehouse Shipment Header"; Deleted: Boolean)
//     var
//         lurl: Text;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: text;
//         WhseShipmentLine: Record "Warehouse Shipment Line";
//         TextJsonObject: JsonObject;
//         JsonToken: JsonToken;
//         BladeStatus: Text;
//         ErrorMsg: Text;
//         ReasonCode: Record "Reason Code";
//         client: HttpClient;
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/' + pWhseShipmentHeader."Blade ID" + '/cancel?expand=*';//check
//         Clear(TextJsonObject);
//         pWhseShipmentHeader.TestField("Reason Code");
//         if ReasonCode.Get(pWhseShipmentHeader."Reason Code") then
//             TextJsonObject.Add('reason', ReasonCode.Description);
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 if not Deleted then begin
//                     BladeStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                     BladeStatus := DelChr(BladeStatus, '=', '"');
//                     ValidateBladeWhseShipmentStatus(BladeStatus, pWhseShipmentHeader);
//                     WhseShipmentLine.Reset();
//                     WhseShipmentLine.SetRange("No.", pWhseShipmentHeader."No.");
//                     WhseShipmentLine.SetRange("Sent to Blade", true);
//                     WhseShipmentLine.ModifyAll("Blade Line Status", WhseShipmentLine."Blade Line Status"::void, false);
//                     if pWhseShipmentHeader.Modify() then//false?
//                         Message('Warehouse Shipment No. %1 has been succcessfully cancelled.', pWhseShipmentHeader."No.");
//                 end;
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure UpdateShippingAddress(var WhseShipmentHeader: Record "Warehouse Shipment Header")
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         Customer: Record Customer;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         ErrorMsg: Text;
//         SalesHeader: Record "Sales Header";
//         client: HttpClient;
//         CountryCode: Code[10];
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/' + WhseShipmentHeader."Blade ID" + '/shipping_address';
//         Clear(TextJsonObject);
//         SalesHeader.get(SalesHeader."Document Type"::Order, WhseShipmentHeader."Sales Order No.");
//         TextJsonObject.Add('first_name', SalesHeader."Ship-to Name");
//         TextJsonObject.Add('last_name', SalesHeader."Ship-to Name");
//         TextJsonObject.Add('address_one', SalesHeader."Ship-to Address");
//         if SalesHeader."Ship-to Address 2" <> '' then
//             TextJsonObject.Add('address_two', SalesHeader."Ship-to Address 2");
//         TextJsonObject.Add('town', SalesHeader."Ship-to City");
//         if (SalesHeader."Ship-to Country/Region Code" <> '') then
//             CountryCode := SalesHeader."Ship-to Country/Region Code"
//         else
//             CountryCode := 'GB';
//         TextJsonObject.Add('country_id', countryCode);
//         if SalesHeader."Ship-to County" <> '' then
//             TextJsonObject.Add('county', SalesHeader."Ship-to County");
//         TextJsonObject.Add('postcode', SalesHeader."Ship-to Post Code");
//         if SalesHeader."Sell-to E-Mail" <> '' then
//             TextJsonObject.Add('email', SalesHeader."Sell-to E-Mail");
//         if SalesHeader."Sell-to Phone No." <> '' then
//             TextJsonObject.Add('mobile', SalesHeader."Sell-to Phone No.");
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then
//                 Message('The shipping address for the Warehouse Shipment %1 has been successfully updated.', WhseShipmentHeader."No.");

//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure UpdateJobPlanningLineShippingAddress(var pJobPlanningLine: Record "Job Planning Line")//(var BladeSalesOrderId:Code[30])
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         ErrorMsg: Text;
//         Job: Record Job;
//         CountryCode: Code[2];
//         client: HttpClient;
//         ShipToAddress: Record "Ship-to Address";
//         ShiptoCodeErr: Label 'Please select Ship-to Code.';
//     begin

//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/' + pJobPlanningLine."Blade ID" + '/shipping_address';
//         Clear(TextJsonObject);
//         if not Job.Get(pJobPlanningLine."Job No.") then;
//         if (Job."Ship-to Code" <> '') then begin
//             ShipToAddress.Get(Job."Sell-to Customer No.", Job."Ship-to Code");
//             ShipToAddress.TestField(City);
//             ShipToAddress.TestField("Post Code");
//         end else
//             Error(ShiptoCodeErr);
//         TextJsonObject.Add('first_name', ShipToAddress.Name);
//         TextJsonObject.Add('last_name', ShipToAddress.Name);
//         TextJsonObject.Add('address_one', ShipToAddress.Address);
//         TextJsonObject.Add('address_two', ShipToAddress."Address 2");
//         TextJsonObject.Add('town', ShipToAddress.City);
//         if (ShipToAddress."Country/Region Code" <> '') then
//             CountryCode := ShipToAddress."Country/Region Code"
//         else
//             CountryCode := 'GB';
//         TextJsonObject.Add('country_id', CountryCode);
//         TextJsonObject.Add('county', ShipToAddress.County);
//         TextJsonObject.Add('postcode', ShipToAddress."Post Code");
//         TextJsonObject.Add('telephone', ShipToAddress."Phone No.");
//         //end;
//         // if Job.Get(pJobPlanningLine."Job No.") then begin
//         //     Job.TestField(Job."Ship-to City");
//         //     Job.TestField(Job."Ship-to Post Code");
//         // end;
//         // TextJsonObject.Add('first_name', Job."Ship-to Name");
//         // TextJsonObject.Add('last_name', Job."Ship-to Name");
//         // TextJsonObject.Add('address_one', Job."Ship-to Address");
//         //if Job."Ship-to Address 2" <> '' then
//         //TextJsonObject.Add('address_two', Job."Ship-to Address 2");
//         //TextJsonObject.Add('town', Job."Ship-to City");
//         //if (Job."Ship-to Country Code" <> '') then
//         //CountryCode := Job."Ship-to Country Code"
//         //else
//         //CountryCode := 'GB';
//         //TextJsonObject.Add('country_id', CountryCode);
//         //if Job."Ship-to County" <> '' then
//         //TextJsonObject.Add('county', Job."Ship-to County");
//         //TextJsonObject.Add('postcode', Job."Ship-to Post Code");
//         //if Job."Ship-to Phone No." <> '' then
//         //TextJsonObject.Add('mobile', Job."Ship-to Phone No.");
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then
//                 Message('The shipping address for the job planning line %1 has been successfully updated.', Job."No.");
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure AddNewJobLine(var pJobPlanningLine: Record "Job Planning Line")
//     var
//         lurl: Text;
//         SalesHeader: Record "Sales Header";
//         TextJsonObject: JsonObject;
//         TextJsonObjectVariation: JsonObject;
//         ltext: text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         gResponseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         BladeLineId: Code[30];
//         ErrorMsg: Text;
//         BladeLineStatus: Text;
//         InputBladeJobReference: Page "Input Blade Job Reference";
//         AddJobPLannningLineConfirm: Label 'Do you want to append this job planning line to the existing Blade Job Order?';
//         JobBladeId: Code[30];
//         JobBladeReference: Code[20];
//         JobPLanningLine: Record "Job Planning Line";
//         Item: Record Item;
//         BladeSku: Code[20];
//         client: HttpClient;
//         BladeReferenceErr: Label 'Please, select the Job Order you want to append this line to.';
//     begin
//         if not Confirm(AddJobPLannningLineConfirm, false) then
//             exit;
//         Message('pjob planning line is %1 %2 %3', pJobPlanningLine."Job No.", pJobPlanningLine."Job Task No.", pJobPlanningLine."Line No.");
//         pJobPlanningLine.TestField("To Be Sent To Blade");
//         pJobPlanningLine.TestField("Qty. to Send to Blade");
//         Clear(InputBladeJobReference);
//         InputBladeJobReference.SetJobFilter(pJobPlanningLine."Job No.");
//         InputBladeJobReference.RunModal();
//         if InputBladeJobReference.ActionConfirmed() then begin
//             JobBladeId := InputBladeJobReference.GetBladeId();
//             JobBladeReference := InputBladeJobReference.GetBladeJobReference();
//         end else
//             Error(BladeReferenceErr);
//         //Commit();//temp
//         JobPLanningLine.Reset();
//         JobPLanningLine.SetCurrentKey("Blade ID");//check this 1803
//         JobPLanningLine.SetRange("Blade ID", JobBladeId);
//         if JobPLanningLine.FindFirst() then
//             GetJobPlanningLineStatuses(JobPLanningLine, true);
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/' + JobBladeId + '/lines';
//         Clear(TextJsonObject);
//         Clear(TextJsonObjectVariation);
//         Item.Get(pJobPlanningLine."No.");
//         if Item."Blade Sku" <> '' then
//             BladeSku := Item."Blade Sku"
//         else
//             BladeSku := pJobPlanningLine."No.";

//         TextJsonObject.Add('variation', '');
//         TextJsonObjectVariation.Add('sku', BladeSku);
//         TextJsonObjectVariation.Add('channel', InventorySetup."Blade Organization ID");
//         TextJsonObject.Replace('variation', TextJsonObjectVariation);
//         TextJsonObject.Add('net_unit_principal', pJobPlanningLine."Unit Price");
//         TextJsonObject.Add('principal_tax_id', 1973);
//         TextJsonObject.Add('discount', 0);
//         TextJsonObject.Add('discount_type', 'percentage');
//         TextJsonObject.Add('quantity', pJobPlanningLine."Qty. to Send to Blade");
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if client.Post(lurl, gcontent, gResponseMsg) then begin
//             gResponseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeLineId := SelectJsonToken(TextJsonObject, '$.data.id').AsValue().AsCode();
//                 BladeLineId := DelChr(BladeLineId, '=', '"');
//                 BladeLineStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeLineStatus := DelChr(BladeLineStatus, '=', '"');
//                 pJobPlanningLine.Validate(pJobPlanningLine."Sent to Blade", true);
//                 pJobPlanningLine.Validate(pJobPlanningLine."Blade ID", JobBladeId);
//                 pJobPlanningLine.Validate(pJobPlanningLine."Qty. Sent to Blade", pJobPlanningLine."Qty. to Send to Blade");
//                 pJobPlanningLine.Validate(pJobPlanningLine."Blade Line ID", BladeLineId);
//                 pJobPlanningLine.Validate("Line Sent to Blade", true);
//                 pJobPlanningLine.Validate("Blade Sku", BladeSku);
//                 pJobPlanningLine.Validate("Blade Reference", JobBladeReference);
//                 //ValidateBladeJobLineStatus(BladeStatus, pJobPlanningLine);
//                 ValidateBladeJobLineStatus(format(JobPLanningLine."Blade Status"), pJobPlanningLine);
//                 Clear(pJobPlanningLine."Qty. to Send to Blade");
//                 Clear(pJobPlanningLine."To Be Sent To Blade");
//                 Clear(pJobPlanningLine."Blade Cancel Reason");
//                 if BladeLineStatus = 'active' then
//                     pJobPlanningLine.Validate(pJobPlanningLine."Blade Line Status", pJobPlanningLine."Blade Line Status"::active);
//                 if BladeLineStatus = 'void' then
//                     pJobPlanningLine.Validate(pJobPlanningLine."Blade Line Status", pJobPlanningLine."Blade Line Status"::void);
//                 if pJobPlanningLine.Modify() then
//                     Message('The Job Planning Line has been successfully added.');
//                 //Commit();
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure GetOrderChannelList()
//     var
//         lurl: Text;
//         gheaders: HttpHeaders;
//         requestMsg: HttpRequestMessage;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         TextJsonObject: JsonObject;
//         TextJsonArray: JsonArray;
//         i: Integer;
//         JsonTokenData: JsonToken;
//         JsonTokenChannelName: JsonToken;
//         channelId: Text;
//         channelName: Text;
//         intChannelId: Integer;
//         WebserviceFailedErr: Label 'The call to webservice failed.';
//         client: HttpClient;
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/channels';
//         gheaders := Client.DefaultRequestHeaders();
//         gheaders.Remove('Accept');
//         gheaders.Add('Accept', 'application/json');
//         gheaders.Remove('User-Agent');
//         gheaders.Add('User-Agent', 'Java/1.7.0_51');
//         gheaders.TryAddWithoutValidation('Content-Type', 'application/json');
//         gheaders.TryAddWithoutValidation('Access-Token', sessiontoken);
//         requestMsg.SetRequestUri(lurl);
//         requestMsg.Method := 'GET';

//         if not Client.Send(requestMsg, responseMsg) then
//             Error(WebserviceFailedErr);
//         responseMsg.Content.ReadAs(lresptext);
//         if responseMsg.HttpStatusCode() = 500 then
//             Error(responseMsg.ReasonPhrase());
//         JsonToken.ReadFrom(lresptext); //maybe
//         TextJsonObject := JsonToken.AsObject();
//         if TextJsonObject.Get('data', JsonToken) then begin
//             TextJsonArray := JsonToken.AsArray();
//             for i := 0 to TextJsonArray.Count - 1 do begin
//                 TextJsonArray.Get(i, JsonTokenData);
//                 TextJsonObject := JsonTokenData.AsObject();
//                 if TextJsonObject.Get('id', JsonTokenData) then
//                     JsonTokenData.WriteTo(channelId);
//                 if TextJsonObject.Get('name', JsonTokenChannelName) then
//                     JsonTokenChannelName.WriteTo(channelName);
//                 channelId := DelChr(channelId, '=', '"');
//                 channelName := DelChr(channelName, '=', '"');
//                 Evaluate(intChannelId, channelId);
//                 OrderChannelDictionary.Add(intChannelId, channelName);
//             end;
//         end;

//     end;

//     procedure AddWhseShipmentLine(var pWarehouseShipmentHeader: Record "Warehouse Shipment Header"; var pWarehouseShipmentLine: Record "Warehouse Shipment Line");
//     var

//         lurl: Text;
//         WhseShipmentHeader: Record "Warehouse Shipment Header";
//         TextJsonObject: JsonObject;
//         TextJsonObjectVariation: JsonObject;
//         SalesLine: Record "Sales Line";
//         ltext: text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         gResponseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         BladeLineId: Code[30];
//         ErrorMsg: Text;
//         BladeLineStatus: Text;
//         ItemNo: Code[20];
//         Item: Record Item;
//         AddWhseShipmentLineConfirm: Label 'Do you want to add a new line with Item No. %1 to the Warehouse Shipment No. %2?';
//         client: HttpClient;
//     begin
//         if not Confirm(AddWhseShipmentLineConfirm, false, pWarehouseShipmentLine."Item No.", pWarehouseShipmentHeader."No.") then
//             exit;
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/' + pWarehouseShipmentHeader."Blade ID" + '/lines';
//         Clear(TextJsonObject);
//         Clear(TextJsonObjectVariation);
//         Clear(ItemNo);
//         SalesLine.get(SalesLine."Document Type"::Order, pWarehouseShipmentLine."Source No.", pWarehouseShipmentLine."Source Line No.");
//         Item.Get(pWarehouseShipmentLine."Item No.");
//         if Item."Blade Sku" <> '' then
//             ItemNo := Item."Blade Sku"
//         else
//             ItemNo := pWarehouseShipmentLine."Item No.";
//         TextJsonObject.Add('variation', '');
//         TextJsonObjectVariation.Add('sku', ItemNo);
//         TextJsonObjectVariation.Add('channel', InventorySetup."Blade Organization ID");
//         TextJsonObject.Replace('variation', TextJsonObjectVariation);
//         TextJsonObject.Add('net_unit_principal', SalesLine."Unit Price");
//         TextJsonObject.Add('principal_tax_id', 1973);
//         TextJsonObject.Add('discount', SalesLine."Line Discount %");
//         TextJsonObject.Add('discount_type', 'percentage');
//         TextJsonObject.Add('quantity', pWarehouseShipmentLine.Quantity);
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if client.Post(lurl, gcontent, gResponseMsg) then begin
//             gResponseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeLineId := SelectJsonToken(TextJsonObject, '$.data.id').AsValue().AsCode();
//                 BladeLineId := DelChr(BladeLineId, '=', '"');
//                 BladeLineStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeLineStatus := DelChr(BladeLineStatus, '=', '"');
//                 pWarehouseShipmentLine.Validate("Sent to Blade", true);
//                 pWarehouseShipmentLine.Validate("Blade Line ID", BladeLineId);
//                 pWarehouseShipmentLine.Validate("Blade Sku", ItemNo);
//                 pWarehouseShipmentLine.Validate("Qty. Sent to Blade", pWarehouseShipmentLine.Quantity);
//                 if BladeLineStatus = 'active' then
//                     pWarehouseShipmentLine.Validate(pWarehouseShipmentLine."Blade Line Status", pWarehouseShipmentLine."Blade Line Status"::active);
//                 if BladeLineStatus = 'void' then
//                     pWarehouseShipmentLine.Validate(pWarehouseShipmentLine."Blade Line Status", pWarehouseShipmentLine."Blade Line Status"::void);
//                 if pWarehouseShipmentLine.Modify() then
//                     Message('Warehouse Line for Shipment No. %1 has been successfully added.', pWarehouseShipmentLine."No.");
//                 Commit();
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure CancelWhseShipmentOrderLine(var pWhseShipmentHeader: Record "Warehouse Shipment Header"; var pWhseShipmentLine: Record "Warehouse Shipment Line");
//     var
//         lurl: Text;
//         ltext: Text;
//         SalesHeader: Record "Sales Header";
//         TextJsonObject: JsonObject;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         BladeLineStatus: Text;
//         ErrorMsg: Text;
//         CancelWhseShipmentLineConfirm: Label 'Do you want to cancel the line with Item No. %1 in the Warehouse Shipment No. %2?';
//         client: HttpClient;
//     begin
//         if not Confirm(CancelWhseShipmentLineConfirm, false, pWhseShipmentLine."Item No.", pWhseShipmentHeader."No.") then
//             exit;
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/' + pWhseShipmentHeader."Blade ID" + '/lines/' + pWhseShipmentLine."Blade Line ID" + '/cancel';
//         pWhseShipmentLine.TestField("Cancel Reason Code");
//         TextJsonObject.Add('reason', pWhseShipmentLine."Cancel Reason Code");
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if client.put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeLineStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeLineStatus := DelChr(BladeLineStatus, '=', '"');
//                 if BladeLineStatus = 'active' then
//                     pWhseShipmentLine.Validate(pWhseShipmentLine."Blade Line Status", pWhseShipmentLine."Blade Line Status"::active);
//                 if BladeLineStatus = 'void' then
//                     pWhseShipmentLine.Validate(pWhseShipmentLine."Blade Line Status", pWhseShipmentLine."Blade Line Status"::void);
//                 pWhseShipmentLine.Validate("Qty. Sent to Blade", 0);
//                 pWhseShipmentLine.Validate("Sent to Blade", false);
//                 if pWhseShipmentLine.Modify() then
//                     Message('Warehouse Line for Shipment No. %1 has been successfully cancelled.', pWhseShipmentLine."No.");
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure UpdateWhseShipmentLineQty(var pWhseShipmentHeader: Record "Warehouse Shipment Header"; var pWhseShipmentLine: Record "Warehouse Shipment Line"; var SuppressMessage: Boolean)
//     var
//         lurl: Text;
//         ltext: Text;
//         TextJsonObject: JsonObject;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         BladeLineStatus: Text;
//         ErrorMsg: Text;
//         UpdateQtySalesOrderLineConfirm: Label 'Do you want to update the quantity for the line %1 item no. %2?';
//         client: HttpClient;
//     begin
//         if not SuppressMessage then
//             if not Confirm(UpdateQtySalesOrderLineConfirm, false, pWhseShipmentLine."Line No.", pWhseShipmentLine."No.") then
//                 exit;
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/' + pWhseShipmentHeader."Blade ID" + '/lines/' + pWhseShipmentLine."Blade Line ID" + '/quantity';
//         TextJsonObject.Add('quantity', pWhseShipmentLine.Quantity);//qty to send to blade should be
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if client.put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeLineStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeLineStatus := DelChr(BladeLineStatus, '=', '"');
//                 if BladeLineStatus = 'active' then
//                     pWhseShipmentLine.Validate(pWhseShipmentLine."Blade Line Status", pWhseShipmentLine."Blade Line Status"::active);
//                 if BladeLineStatus = 'void' then
//                     pWhseShipmentLine.Validate(pWhseShipmentLine."Blade Line Status", pWhseShipmentLine."Blade Line Status"::void);
//                 pWhseShipmentLine.Validate("Qty. Sent to Blade", pWhseShipmentLine.Quantity);
//                 if pWhseShipmentLine.Modify() then
//                     Message('Warehouse Line Quantity for Shipment No. %1 has been successfully updated.', pWhseShipmentLine."No.");
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure UpdateJobPlannningLineQty(var pJobPlanningLine: Record "Job Planning Line")
//     var
//         lurl: Text;
//         ltext: Text;
//         TextJsonObject: JsonObject;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         BladeLineStatus: Text;
//         ErrorMsg: Text;
//         client: HttpClient;
//     begin
//         pJobPlanningLine.TestField("Qty. to Send to Blade");
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/' + pJobPlanningLine."Blade ID" + '/lines/' + pJobPlanningLine."Blade Line ID" + '/quantity';
//         TextJsonObject.Add('quantity', pJobPlanningLine."Qty. to Send to Blade");//qty to send to blade should be
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if client.put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeLineStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeLineStatus := DelChr(BladeLineStatus, '=', '"');
//                 if BladeLineStatus = 'active' then
//                     pJobPlanningLine.Validate(pJobPlanningLine."Blade Line Status", pJobPlanningLine."Blade Line Status"::active);
//                 if BladeLineStatus = 'void' then
//                     pJobPlanningLine.Validate(pJobPlanningLine."Blade Line Status", pJobPlanningLine."Blade Line Status"::void);
//                 pJobPlanningLine.Validate("Qty. Sent to Blade", pJobPlanningLine."Qty. to Send to Blade");
//                 Clear(pJobPlanningLine."Qty. to Send to Blade");
//                 if pJobPlanningLine.Modify() then
//                     Message('Job Planning Line Quantity has been successfully updated.');
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure CreateWarehouseReceiptOrder(pWhseReceiptHeader: Record "Warehouse Receipt Header")
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         TextJsonObjectOrder: JsonObject;
//         TextJsonObjectLines: JsonObject;
//         TextJsonObjectLineVariation: JsonObject;
//         TextJsonObjectGoodsIn: JsonObject;
//         TextJsonArrayReferences: JsonArray;
//         TextJsonGoodsIn: JsonObject;
//         TextJsonArrayLine: JsonArray;
//         TextJsonArrayGoodsIn: JsonArray;
//         WarehouseReceiptLine: Record "Warehouse Receipt Line";
//         OldWhseReceiptHeader: Record "Warehouse Receipt Header";
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         gResponseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         BladeId: Text;
//         BladeStatus: Text;
//         Item: Record Item;
//         ErrorMsg: Text;
//         TextLinesArrayResp: text;
//         i: Integer;
//         j: Integer;
//         JsonTokenId: JsonToken;
//         JsonTokenSku: JsonToken;
//         JsonTokenGoodsIn: JsonToken;
//         BladeSku: Text;
//         BladeLineId: Text;
//         BladeGoodsInId: Text;
//         BladeLineStatus: Text;
//         PurchaseHeader: Record "Purchase Header";
//         PurchaseLine: Record "Purchase Line";
//         InputGoodsInInfo: Page "Input Blade GoodsIn";
//         ExpectedPallets: Integer;
//         ExpectedCartons: Integer;
//         ShippingCompany: Text[50];
//         TrackingNumber: Code[20];
//         ShippingMethod: Text[5];
//         ItemNo: Code[20];
//         NothingToSendErr: Label 'There is nothing to send to Blade';
//         BladeReference: Code[20];
//         client: HttpClient;
//     begin
//         WarehouseReceiptLine.reset();
//         WarehouseReceiptLine.SetRange(WarehouseReceiptLine."No.", pWhseReceiptHeader."No.");
//         if not WarehouseReceiptLine.FindSet() then
//             Error(NothingToSendErr);

//         Clear(InputGoodsInInfo);
//         InputGoodsInInfo.RunModal();
//         if not InputGoodsInInfo.ActionConfirmed() then
//             exit;
//         ExpectedPallets := InputGoodsInInfo.GetExpectedPallets();
//         ExpectedCartons := InputGoodsInInfo.GetExpectedCartons();
//         ShippingCompany := InputGoodsInInfo.GetShippingCompany();
//         TrackingNumber := InputGoodsInInfo.GetTrackingNumber();
//         ShippingMethod := InputGoodsInInfo.GetShippingMethod();
//         if CurrentDateTime > ExpiryDateTime then begin
//             Authentication();
//         end;

//         lurl := InventorySetup."Blade Base Url" + '/purchase_orders?expand=*';
//         clear(TextJsonObject);
//         Clear(TextJsonObjectOrder);
//         clear(TextJsonArrayReferences);
//         Clear(TextJsonArrayLine);
//         Clear(TextJsonObjectLines);
//         OldWhseReceiptHeader.Copy(pWhseReceiptHeader);
//         BladeReference := GetNextBladeReferenceWhseReceipt(OldWhseReceiptHeader);
//         PurchaseHeader.get(PurchaseHeader."Document Type"::Order, pWhseReceiptHeader."Purchase Order No.");
//         //PurchaseHeader.testfield("Expected Receipt Date");
//         TextJsonObject.Add('product_channel_id', InventorySetup."Blade Organization ID");
//         TextJsonObject.Add('product_component_supplier_id', 1501);
//         TextJsonObject.Add('references', '');
//         TextJsonObjectOrder.Add('name', BladeReference);
//         TextJsonObjectOrder.Add('value', pWhseReceiptHeader."Purchase Order No." + '_' + pWhseReceiptHeader."No.");
//         TextJsonArrayReferences.Add(TextJsonObjectOrder);
//         TextJsonObject.Replace('references', TextJsonArrayReferences);
//         TextJsonObject.Add('warehouse_code', 'CHR');//testing
//         TextJsonObject.Add('currency_code', GLSetup."LCY Code");
//         TextJsonObject.Add('goodsin', '');
//         TextJsonGoodsIn.Add('expected_pallets', ExpectedPallets);
//         TextJsonGoodsIn.Add('expected_cartons', ExpectedCartons);
//         TextJsonGoodsIn.Add('shipping_company', ShippingCompany);
//         TextJsonGoodsIn.Add('tracking_number', TrackingNumber);
//         TextJsonGoodsIn.Add('shipping_method', ShippingMethod);
//         TextJsonGoodsIn.Add('expected_delivery_date', PurchaseHeader."Expected Receipt Date");
//         TextJsonObject.Replace('goodsin', TextJsonGoodsIn);
//         TextJsonObject.Add('lines', '');
//         TextJsonObjectLines.Add('sku', '');
//         TextJsonObjectLines.Add('quantity', '');
//         TextJsonObjectLines.Add('cost_price', '');
//         TextJsonObjectLines.Add('duty', '');
//         repeat
//             //Clear(BladeSku);
//             Clear(ItemNo);
//             Item.get(WarehouseReceiptLine."Item No.");
//             if Item."Blade Sku" <> '' then
//                 //BladeSku := Item."Blade Sku"
//                 ItemNo := Item."Blade Sku"
//             else
//                 //BladeSku := Item."No.";
//                 ItemNo := WarehouseReceiptLine."Item No.";
//             WarehouseReceiptLine.Validate("Blade Sku", ItemNo);
//             WarehouseReceiptLine.Modify();//test
//             PurchaseLine.get(PurchaseLine."Document Type"::Order, WarehouseReceiptLine."Source No.", WarehouseReceiptLine."Source Line No.");
//             TextJsonObjectLines.Replace('sku', ItemNo);
//             TextJsonObjectLines.Replace('quantity', WarehouseReceiptLine."Qty. to Receive");
//             TextJsonObjectLines.Replace('cost_price', PurchaseLine."Unit Cost");
//             TextJsonObjectLines.Replace('duty', 0);
//             TextJsonArrayLine.Add(TextJsonObjectLines.Clone());
//         until WarehouseReceiptLine.Next() = 0;
//         TextJsonObject.Replace('lines', TextJsonArrayLine);
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if client.Post(lurl, gcontent, gResponseMsg) then begin
//             gResponseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 BladeId := SelectJsonToken(TextJsonObject, '$.data.id').AsValue().AsCode();
//                 BladeStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//                 BladeId := DelChr(BladeId, '=', '"');
//                 BladeStatus := DelChr(BladeStatus, '=', '"');
//                 TextJsonObjectLines := JsonToken.AsObject();
//                 if TextJsonObjectLines.Get('lines', JsonToken) then begin
//                     Clear(TextJsonArrayLine);
//                     Clear(TextJsonObjectLineVariation);
//                     TextJsonArrayLine := JsonToken.AsArray();
//                     TextJsonArrayLine.WriteTo(TextLinesArrayResp);
//                     for i := 0 to TextJsonArrayLine.Count - 1 do begin
//                         TextJsonArrayLine.Get(i, JsonTokenId);
//                         TextJsonObjectLineVariation := JsonTokenId.AsObject();
//                         if TextJsonObjectLineVariation.Get('id', JsonTokenId) then
//                             JsonTokenId.WriteTo(BladeLineId);
//                         BladeSku := SelectJsonToken(TextJsonObjectLineVariation, '$.component.sku').AsValue().AsText();
//                         BladeLineId := DelChr(BladeLineId, '=', '"');
//                         BladeSku := DelChr(BladeSku, '=', '"');
//                         WarehouseReceiptLine.Reset();
//                         WarehouseReceiptLine.SetRange(WarehouseReceiptLine."No.", pWhseReceiptHeader."No.");
//                         WarehouseReceiptLine.SetRange(WarehouseReceiptLine."Blade Sku", BladeSku);
//                         if WarehouseReceiptLine.FindFirst() then begin
//                             WarehouseReceiptLine.Validate("Blade Line ID", BladeLineId);
//                             WarehouseReceiptLine.Validate("Sent to Blade", true);
//                             WarehouseReceiptLine.Validate("Qty. Sent to Blade", WarehouseReceiptLine."Qty. to Receive");
//                             WarehouseReceiptLine.Modify();
//                         end;
//                     end;
//                 end;
//                 if TextJsonObjectLines.Get('goodsins', JsonToken) then begin
//                     Clear(TextJsonArrayGoodsIn);
//                     TextJsonArrayGoodsIn := JsonToken.AsArray();
//                     for j := 0 to TextJsonArrayGoodsIn.Count - 1 do begin
//                         TextJsonArrayGoodsIn.Get(j, JsonTokenGoodsIn);
//                         TextJsonGoodsIn := JsonTokenGoodsIn.AsObject();
//                         BladeGoodsInId := SelectJsonToken(TextJsonGoodsIn, '$.id').AsValue().AsText();
//                         BladeLineStatus := SelectJsonToken(TextJsonGoodsIn, '$.status').AsValue().AsText();
//                         BladeGoodsInId := DelChr(BladeGoodsInId, '=', '"');
//                         BladeLineStatus := DelChr(BladeLineStatus, '=', '"');
//                         WarehouseReceiptLine.Reset();
//                         //WarehouseReceiptLine.SetRange(WarehouseReceiptLine."Document Type", WarehouseReceiptLine."Document Type"::Order);
//                         WarehouseReceiptLine.SetRange(WarehouseReceiptLine."No.", pWhseReceiptHeader."No.");
//                         ValidateBladeWhseReceiptOrderLineStatus(BladeLineStatus, WarehouseReceiptLine);
//                         WarehouseReceiptLine.ModifyAll("Blade Line Status", WarehouseReceiptLine."Blade Line Status");//check
//                     end;
//                 end;

//                 ValidateBladeWhseReceiptOrderStatus(BladeStatus, pWhseReceiptHeader);
//                 pWhseReceiptHeader.validate(pWhseReceiptHeader."Sent to Blade", true);
//                 pWhseReceiptHeader.validate("Blade ID", BladeId);
//                 pWhseReceiptHeader.Validate("Blade Reference", BladeReference);
//                 if pWhseReceiptHeader.Modify() then
//                     Message('Purchase Order %1 has been succcessfully sent.', pWhseReceiptHeader."No.");
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure SynchWarehouseReceiptStatus(var pWarehouseReceiptHeader: Record "Warehouse Receipt Header")
//     var
//         lurl: Text;
//         gheaders: HttpHeaders;
//         requestMsg: HttpRequestMessage;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         TextJsonArray: JsonArray;
//         ItemsJsonArray: JsonArray;
//         i: Integer;
//         j: Integer;
//         JsonToken: JsonToken;
//         TextJsonObject: JsonObject;
//         TextJsonObjectGoodsIn: JsonObject;
//         TextJsonItem: JsonObject;
//         textJsonArrayOrderReference: JsonArray;
//         JsonTokenData: JsonToken;
//         JsonTokenReference: JsonToken;
//         JsonTokenGoodsIns: JsonToken;
//         JsonTokenGoodsIn: JsonToken;
//         JsonTokenItems: JsonToken;
//         JsonTokenItem: JsonToken;
//         BladeSku: Text;
//         BladeId: Text;
//         JsonTokenStatus: JsonToken;
//         JsonTokenChannelId: JsonToken;
//         BladeStatus: Text;
//         BladeLineStatus: Text;
//         ChannelId: Text;
//         intChannelId: Integer;
//         BladeQtyReceived: Text;
//         decBladeQtyReceived: Decimal;
//         WarehouseReceiptLine: Record "Warehouse Receipt Line";
//         ErrorMsg: text;
//         WebserviceFailedErr: Label 'The call to webservice failed.';
//         BladeOverReceiptQty: Decimal;
//         client: HttpClient;
//     begin
//         if CurrentDateTime > ExpiryDateTime then
//             Authentication();

//         lurl := InventorySetup."Blade Base Url" + '/purchase_orders/' + pWarehouseReceiptHeader."Blade ID" + '/?expand=*';
//         gheaders := client.DefaultRequestHeaders();
//         gheaders.Remove('Accept');
//         gheaders.Add('Accept', 'application/json');
//         gheaders.Remove('User-Agent');
//         gheaders.Add('User-Agent', 'Java/1.7.0_51');
//         gheaders.TryAddWithoutValidation('Content-Type', 'application/json');
//         gheaders.TryAddWithoutValidation('Access-Token', sessiontoken);
//         requestMsg.SetRequestUri(lurl);
//         requestMsg.Method := 'GET';
//         if not Client.Send(requestMsg, responseMsg) then
//             Error(WebserviceFailedErr);
//         responseMsg.Content.ReadAs(lresptext);
//         EntryNo := InsertLog(BladeId, lurl);
//         if responseMsg.HttpStatusCode() = 500 then
//             Error(responseMsg.ReasonPhrase());
//         if (responseMsg.HttpStatusCode <> 200) then
//             Error(responseMsg.ReasonPhrase());
//         Clear(TextJsonObject);
//         Clear(TextJsonObjectGoodsIn);
//         JsonToken.ReadFrom(lresptext);
//         TextJsonObject := JsonToken.AsObject();
//         if TextJsonObject.Get('data', JsonToken) then begin
//             BladeId := SelectJsonToken(TextJsonObject, '$.data.id').AsValue().AsCode();
//             ChannelId := SelectJsonToken(TextJsonObject, '$.data.product_channel_id').AsValue().AsCode();
//             BladeStatus := SelectJsonToken(TextJsonObject, '$.data.status').AsValue().AsText();
//             BladeId := DelChr(BladeId, '=', '"');
//             ChannelId := DelChr(ChannelId, '=', '"');
//             BladeStatus := DelChr(BladeStatus, '=', '"');
//             Evaluate(intChannelId, ChannelId);
//             if (intChannelId = InventorySetup."Blade Organization ID") then begin
//                 InsertLog(StrSubstNo('Purchase Order No. %1,Blade ID %2', pWarehouseReceiptHeader."No.", BladeId), lurl);
//                 ValidateBladeWhseReceiptOrderStatus(BladeStatus, pWarehouseReceiptHeader);
//                 pWarehouseReceiptHeader.Validate(pWarehouseReceiptHeader."Sent to Blade", true);//needed?
//                 TextJsonObjectGoodsIn := JsonToken.AsObject();//test
//                 if TextJsonObjectGoodsIn.Get('goodsins', JsonToken) then begin
//                     Clear(TextJsonArray);
//                     TextJsonArray := JsonToken.AsArray();
//                     TextJsonObjectGoodsIn.WriteTo(lresptext);
//                     for i := 0 to TextJsonArray.Count - 1 do begin
//                         TextJsonArray.Get(i, JsonTokenGoodsIn);
//                         TextJsonObjectGoodsIn := JsonTokenGoodsIn.AsObject();
//                         BladeLineStatus := SelectJsonToken(TextJsonObjectGoodsIn, '$.status').AsValue().AsText();
//                         BladeLineStatus := DelChr(BladeLineStatus, '=', '"');
//                         WarehouseReceiptLine.Reset();
//                         WarehouseReceiptLine.SetRange("No.", pWarehouseReceiptHeader."No.");
//                         if WarehouseReceiptLine.FindSet() then begin
//                             repeat
//                                 ValidateBladeWhseReceiptOrderLineStatus(BladeLineStatus, WarehouseReceiptLine);
//                                 WarehouseReceiptLine.Modify()
//                             until WarehouseReceiptLine.Next() = 0;
//                         end;
//                         if TextJsonObjectGoodsIn.Get('items', JsonTokenItems) then begin
//                             ItemsJsonArray := JsonTokenItems.AsArray();
//                             for j := 0 to ItemsJsonArray.Count - 1 do begin
//                                 if ItemsJsonArray.Get(j, JsonTokenItem) then begin
//                                     TextJsonItem := JsonTokenItem.AsObject();
//                                     BladeQtyReceived := SelectJsonToken(TextJsonItem, '$.quantity').AsValue().AsText();
//                                     BladeSku := SelectJsonToken(TextJsonItem, '$.component.sku').AsValue().AsText();
//                                     BladeQtyReceived := DelChr(BladeQtyReceived, '=', '"');
//                                     BladeSku := DelChr(BladeSku, '=', '"');
//                                     Evaluate(decBladeQtyReceived, BladeQtyReceived);
//                                     Clear(BladeOverReceiptQty);
//                                     WarehouseReceiptLine.Reset();
//                                     WarehouseReceiptLine.SetRange(WarehouseReceiptLine."No.", pWarehouseReceiptHeader."No.");
//                                     //WarehouseReceiptLine.SetRange(WarehouseReceiptLine."Qty. Received", 0);//check
//                                     WarehouseReceiptLine.SetRange(WarehouseReceiptLine."Item No.", BladeSku);
//                                     if WarehouseReceiptLine.FindFirst() then begin
//                                         if (decBladeQtyReceived > WarehouseReceiptLine."Qty. to Receive") then begin//and (WarehouseReceiptLine."Qty. Received" = 0) then begin
//                                             //and (WarehouseReceiptLine."Qty. Received" = 0) then begin
//                                             BladeOverReceiptQty := decBladeQtyReceived - WarehouseReceiptLine."Qty. to Receive";
//                                             WarehouseReceiptLine.Validate("Over-Receipt Quantity", BladeOverReceiptQty);
//                                         end;
//                                         // if decBladeQtyReceived < WarehouseReceiptLine."Qty. to Receive" then begin
//                                         //     WarehouseReceiptLine.Validate(Quantity,decBladeQtyReceived);
//                                         // end;

//                                         //end;
//                                         WarehouseReceiptLine.Validate(WarehouseReceiptLine."Qty. to Receive", decBladeQtyReceived);
//                                         WarehouseReceiptLine.Modify();
//                                     end;
//                                 end;
//                             end;
//                         end;

//                     end;
//                 end;
//                 pWarehouseReceiptHeader.Modify();
//             end;
//         end;
//         if TextJsonObject.Get('error', JsonToken) then begin
//             ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//             Error(ErrorMsg);
//         end;
//     end;

//     procedure GetWhseShipmentStatuses(HideDialog: Boolean)
//     var
//         lurl: Text;
//         gheaders: HttpHeaders;
//         requestMsg: HttpRequestMessage;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         TextJsonObject: JsonObject;
//         TextJsonObjectValue: JsonValue;
//         TextJsonArray: JsonArray;
//         I: Integer;
//         JsonTokenData: JsonToken;
//         JsonTokenStatus: JsonToken;
//         JsonTokenChannelId: JsonToken;
//         BladeId: Text;
//         ChannelId: Text;
//         BladeStatus: Text;
//         intChannelId: Integer;
//         PurchaseHeader: Record "Purchase Header";
//         ErrorMsg: Text;
//         WhseShipmentHeader: Record "Warehouse Shipment Header";
//         intBladeId: Integer;
//         ltext: Text;
//         gcontent: HttpContent;
//         client: HttpClient;
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/bulk_statuses';
//         Clear(TextJsonObject);
//         Clear(TextJsonObjectValue);
//         Clear(TextJsonArray);
//         //TextJsonObject.Add('order_goodsout_ids', '');temp moved down
//         WhseShipmentHeader.Reset();
//         WhseShipmentHeader.SetFilter("Blade ID", '<>%1', '');
//         WhseShipmentHeader.SetRange("Sent to Blade", true);
//         if WhseShipmentHeader.FindFirst() then begin
//             TextJsonObject.Add('order_goodsout_ids', '');
//             repeat
//                 Evaluate(intBladeId, WhseShipmentHeader."Blade ID");
//                 TextJsonObjectValue.SetValue(intBladeId);
//                 TextJsonArray.Add(TextJsonObjectValue);
//             until WhseShipmentHeader.Next() = 0;
//             //end; temp moved down
//             TextJsonObject.Replace('order_goodsout_ids', TextJsonArray);
//             TextJsonObject.WriteTo(ltext);
//             gcontent.WriteFrom(ltext);
//             gcontent.ReadAs(ltext);
//             EntryNo := InsertLog(ltext, lurl);
//             gcontent.GetHeaders(gheaders);
//             gheaders.Remove('Content-Type');
//             gheaders.Add('Content-Type', 'application/json');
//             gheaders.Remove('Access-Token');
//             gheaders.Add('Access-Token', sessiontoken);
//             if Client.Put(lurl, gcontent, responseMsg) then begin
//                 responseMsg.Content.ReadAs(lresptext);
//                 ModifyLogwithResponse(lresptext, EntryNo);
//                 Clear(TextJsonObject);
//                 Clear(TextJsonArray);
//                 JsonToken.ReadFrom(lresptext);
//                 TextJsonObject := JsonToken.AsObject();
//                 if TextJsonObject.Get('data', JsonToken) then begin
//                     TextJsonArray := JsonToken.AsArray();
//                     for i := 0 to TextJsonArray.Count - 1 do begin
//                         TextJsonArray.Get(i, JsonTokenData);
//                         TextJsonObject := JsonTokenData.AsObject();
//                         if TextJsonObject.Get('order_goodsout_id', JsonTokenData) then
//                             JsonTokenData.WriteTo(BladeId);
//                         if TextJsonObject.Get('status', JsonTokenStatus) then
//                             JsonTokenStatus.WriteTo(BladeStatus);
//                         BladeId := DelChr(BladeId, '=', '"');
//                         BladeStatus := DelChr(BladeStatus, '=', '"');
//                         WhseShipmentHeader.Reset();
//                         WhseShipmentHeader.SetRange("Blade ID", BladeId);
//                         if WhseShipmentHeader.FindFirst() then begin
//                             ValidateBladeWhseShipmentStatus(BladeStatus, WhseShipmentHeader);
//                             WhseShipmentHeader.Modify();
//                         end;
//                     end;
//                     if not HideDialog then
//                         Message('Warehouse Shipments have been successfully synchronized with Blade.');
//                 end;

//                 if TextJsonObject.Get('error', JsonToken) then begin
//                     ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                     Error(ErrorMsg);
//                 end;
//             end;//moved here
//         end;
//     end;

//     procedure GetWhseShipmentStatus(var pWhseShipmentHeader: Record "Warehouse Shipment Header")//(var WhseShipmentHeader:Record "Warehouse Shipment Header")
//     var
//         lurl: Text;
//         gheaders: HttpHeaders;
//         requestMsg: HttpRequestMessage;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         TextJsonObject: JsonObject;
//         TextJsonObjectValue: JsonValue;
//         TextJsonArray: JsonArray;
//         I: Integer;
//         JsonTokenData: JsonToken;
//         JsonTokenStatus: JsonToken;
//         JsonTokenChannelId: JsonToken;
//         BladeId: Text;
//         ChannelId: Text;
//         BladeStatus: Text;
//         intChannelId: Integer;
//         PurchaseHeader: Record "Purchase Header";
//         ErrorMsg: Text;
//         intBladeId: Integer;
//         ltext: Text;
//         gcontent: HttpContent;
//         client: HttpClient;
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/bulk_statuses';
//         Clear(TextJsonObject);
//         Clear(TextJsonObjectValue);
//         Clear(TextJsonArray);
//         TextJsonObject.Add('order_goodsout_ids', '');
//         Evaluate(intBladeId, pWhseShipmentHeader."Blade ID");
//         TextJsonObjectValue.SetValue(intBladeId);
//         TextJsonArray.Add(TextJsonObjectValue);
//         TextJsonObject.Replace('order_goodsout_ids', TextJsonArray);
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             Clear(TextJsonArray);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 TextJsonArray := JsonToken.AsArray();
//                 for i := 0 to TextJsonArray.Count - 1 do begin
//                     TextJsonArray.Get(i, JsonTokenData);
//                     TextJsonObject := JsonTokenData.AsObject();
//                     if TextJsonObject.Get('order_goodsout_id', JsonTokenData) then
//                         JsonTokenData.WriteTo(BladeId);
//                     if TextJsonObject.Get('status', JsonTokenStatus) then
//                         //BladeInventory := JsonTokenSaleable.AsValue().AsDecimal();  
//                         JsonTokenStatus.WriteTo(BladeStatus);
//                     BladeId := DelChr(BladeId, '=', '"');
//                     BladeStatus := DelChr(BladeStatus, '=', '"');
//                     ValidateBladeWhseShipmentStatus(BladeStatus, pWhseShipmentHeader);
//                     pWhseShipmentHeader.Modify();
//                     Commit();
//                     Sleep(10);
//                 end;
//             end;
//             if TextJsonObject.Get('error', JsonToken) then begin
//                 ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                 Error(ErrorMsg);
//             end;
//         end;
//     end;

//     procedure GetJobPlanningLineStatuses(var pJobPlanningLine: Record "Job Planning Line"; HideDialog: boolean)//(var WhseShipmentHeader:Record "Warehouse Shipment Header")
//     var
//         lurl: Text;
//         gheaders: HttpHeaders;
//         requestMsg: HttpRequestMessage;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         JsonToken: JsonToken;
//         TextJsonObject: JsonObject;
//         TextJsonObjectValue: JsonValue;
//         TextJsonArray: JsonArray;
//         I: Integer;
//         JsonTokenData: JsonToken;
//         JsonTokenStatus: JsonToken;
//         JsonTokenChannelId: JsonToken;
//         BladeId: Text;
//         ChannelId: Text;
//         BladeStatus: Text;
//         intChannelId: Integer;
//         ErrorMsg: Text;
//         intBladeId: Integer;
//         ltext: Text;
//         gcontent: HttpContent;
//         client: HttpClient;
//     begin
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/orders/goodsouts/bulk_statuses';
//         Clear(TextJsonObject);
//         Clear(TextJsonObjectValue);
//         Clear(TextJsonArray);
//         //TextJsonObject.Add('order_goodsout_ids', '');//moved down
//         //JobPlanningLine.Reset();
//         // JobPlanningLine.SetFilter("Blade ID", '<>%1', '');
//         // JobPlanningLine.SetRange("Sent to Blade", true);
//         //JobPlanningLine.SetFilter("Blade Status",'<>%1',JobPlanningLine."Blade Status"::despatched);
//         if pJobPlanningLine.FindFirst() then begin
//             TextJsonObject.Add('order_goodsout_ids', '');
//             repeat
//                 Evaluate(intBladeId, pJobPlanningLine."Blade ID");
//                 TextJsonObjectValue.SetValue(intBladeId);
//                 TextJsonArray.Add(TextJsonObjectValue);
//             until pJobPlanningLine.Next() = 0;
//             //end;moved down
//             TextJsonObject.Replace('order_goodsout_ids', TextJsonArray);
//             TextJsonObject.WriteTo(ltext);
//             //Message('request text is %1', ltext);//uz
//             gcontent.WriteFrom(ltext);
//             gcontent.ReadAs(ltext);
//             EntryNo := InsertLog(ltext, lurl);
//             gcontent.GetHeaders(gheaders);
//             gheaders.Remove('Content-Type');
//             gheaders.Add('Content-Type', 'application/json');
//             gheaders.Remove('Access-Token');
//             gheaders.Add('Access-Token', sessiontoken);
//             if Client.Put(lurl, gcontent, responseMsg) then begin
//                 responseMsg.Content.ReadAs(lresptext);
//                 //Message('response text is %1', lresptext);
//                 ModifyLogwithResponse(lresptext, EntryNo);
//                 Clear(TextJsonObject);
//                 Clear(TextJsonArray);
//                 JsonToken.ReadFrom(lresptext);
//                 TextJsonObject := JsonToken.AsObject();
//                 if TextJsonObject.Get('data', JsonToken) then begin
//                     TextJsonArray := JsonToken.AsArray();
//                     for i := 0 to TextJsonArray.Count - 1 do begin
//                         TextJsonArray.Get(i, JsonTokenData);
//                         TextJsonObject := JsonTokenData.AsObject();
//                         if TextJsonObject.Get('order_goodsout_id', JsonTokenData) then
//                             JsonTokenData.WriteTo(BladeId);
//                         if TextJsonObject.Get('status', JsonTokenStatus) then
//                             JsonTokenStatus.WriteTo(BladeStatus);
//                         BladeId := DelChr(BladeId, '=', '"');
//                         BladeStatus := DelChr(BladeStatus, '=', '"');
//                         pJobPlanningLine.Reset();
//                         pJobPlanningLine.SetCurrentKey("Job No.", "job task no.", "Line no.", "Blade ID");
//                         pJobPlanningLine.SetRange("Blade ID", BladeId);
//                         if pJobPlanningLine.FindSet() then begin
//                             repeat
//                                 //if (BladeId = '2483581') then
//                                 //Message('line no is %1', pJobPlanningLine."Line No.");
//                                 ValidateBladeJobLineStatus(BladeStatus, pJobPlanningLine);
//                                 pJobPlanningLine.validate("Qty. to Transfer to Journal", pJobPlanningLine."Qty. Sent to Blade");
//                                 pJobPlanningLine.Modify();
//                             until pJobPlanningLine.Next() = 0;
//                         end;
//                     end;
//                     if not HideDialog then
//                         Message('Job planning lines have been successfully synchronized with Blade.');
//                 end;
//                 if TextJsonObject.Get('error', JsonToken) then begin
//                     ErrorMsg := SelectJsonToken(TextJsonObject, '$.error.message').AsValue().AsText();
//                     Error(ErrorMsg);
//                 end;
//             end;//moved here
//         end;
//     end;

//     procedure GetAvailableQtyJob(var pJob: Record Job; var pJobPlanningLine: Record "Job Planning Line") //added second parameter 22/03
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         TextJsonArray: JsonArray;
//         TextJsonObjectValue: JsonValue;
//         JobPlanningLine: Record "Job Planning Line";
//         JobPlanningLineBuffer: record "Job Planning Line" temporary;
//         //Item:Record item;
//         intBladeItemId: Integer;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         Client: HttpClient;
//         JsonToken: JsonToken;
//         i: Integer;
//         JsonTokentData: JsonToken;
//         BladeId: Text;
//         JsonTokenAvailable: JsonToken;
//         BladeAvailableQty: Text;
//         decBladeAvailableQty: Decimal;
//         Window: Dialog;
//         Text000: Label 'Updating the available qty. #1##########';
//     begin
//         //Window.Open(Text000);
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/products/variations/stocks';
//         Clear(TextJsonObject);
//         Clear(TextJsonObjectValue);
//         Clear(TextJsonArray);
//         TextJsonObject.Add('product_variation_id', '');
//         //Message('pjobplanningline is %1 %2 %3', pJobPlanningLine."Job No.", pJobPlanningLine."Job Task No.", pJobPlanningLine."Line No.");
//         //SetJobPlanningLineFiltersForMarkedToBeSent(JobPlanningLine, pJob);
//         // if JobPlanningLine.Findset() then begin
//         //     repeat
//         //         //Item.Get(JobPlanningLine."No.");
//         //         //if (Item."Sent to Blade") and (Item."Blade Item ID" <> '') then begin
//         //         JobPlanningLine.CalcFields(JobPlanningLine."Blade Item ID");
//         //         Evaluate(intBladeItemId, JobPlanningLine."Blade Item ID");
//         //         TextJsonObjectValue.SetValue(intBladeItemId);
//         //         TextJsonArray.Add(TextJsonObjectValue);
//         //     //end;
//         //     until JobPlanningLine.Next() = 0;
//         // end;//replaced with below 22/03
//         // JobPlanningLine.Copy(pJobPlanningLine);
//         // if pJobPlanningLine.FindSet() then begin
//         //     repeat
//         //         pJobPlanningLine.CalcFields(pJobPlanningLine."Blade Item ID");
//         //         if (pJobPlanningLine."Blade Item ID" <> '') then begin
//         //             Evaluate(intBladeItemId, pJobPlanningLine."Blade Item ID");
//         //             TextJsonObjectValue.SetValue(intBladeItemId);
//         //             TextJsonArray.Add(TextJsonObjectValue);
//         //         end;
//         //     until pJobPlanningLine.Next() = 0;
//         // end;
//         //if not pJobPlanningLine.FindSet() then;
//         JobPlanningLine.Copy(pJobPlanningLine);
//         //if pJobPlanningLine.FindSet() then
//         //Message('count pjoblpanninglines is %1 in get available stock function', format(pJobPlanningLine.Count));
//         if pJobPlanningLine.FindFirst() then begin
//             repeat
//                 pJobPlanningLine.CalcFields(pJobPlanningLine."Blade Item ID");
//                 if (pJobPlanningLine."Blade Item ID" <> '') then begin
//                     Evaluate(intBladeItemId, pJobPlanningLine."Blade Item ID");
//                     TextJsonObjectValue.SetValue(intBladeItemId);
//                     TextJsonArray.Add(TextJsonObjectValue);
//                     //Message('goes once');
//                 end;
//             until pJobPlanningLine.Next() = 0;
//         end;
//         TextJsonObject.Replace('product_variation_id', TextJsonArray);
//         TextJsonObject.Add('warehouse_code', 'CHR');
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         Message('request message is %1', ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             Clear(TextJsonArray);
//             JsonToken.ReadFrom(lresptext);
//             Message('response message is %1', lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 TextJsonArray := JsonToken.AsArray();
//                 for i := 0 to TextJsonArray.Count - 1 do begin
//                     TextJsonArray.Get(i, JsonTokentData);
//                     TextJsonObject := JsonTokentData.AsObject();
//                     if TextJsonObject.Get('product_variation_id', JsonTokentData) then
//                         JsonTokentData.WriteTo(BladeId);
//                     if TextJsonObject.Get('available', JsonTokenAvailable) then
//                         JsonTokenAvailable.WriteTo(BladeAvailableQty);
//                     BladeId := DelChr(BladeId, '=', '"');
//                     BladeAvailableQty := DelChr(BladeAvailableQty, '=', '"');
//                     Evaluate(decBladeAvailableQty, BladeAvailableQty);
//                     //Window.Open(Text000);
//                     JobPlanningLine.Reset();
//                     JobPlanningLine.SetRange("Job No.", pJob."No.");
//                     //JobPlanningLine.SetRange("Job Task No.", pJobPlanningLine."Job Task No.");
//                     //JobPlanningLine.SetRange("Line No.", pJobPlanningLine."Line No.");
//                     JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Item);
//                     JobPlanningLine.SetRange("Blade Item ID", BladeId);
//                     JobPlanningLine.SetRange("To Be Sent To Blade", true);
//                     JobPlanningLine.ModifyAll("Available Qty.", decBladeAvailableQty);//replaced with below 22/03
//                     // pJobPlanningLine.Reset();
//                     // pJobPlanningLine.SetRange("Job No.", pJob."No.");
//                     // pJobPlanningLine.SetRange(Type, pJobPlanningLine.Type::Item);
//                     // pJobPlanningLine.SetFilter("Blade Item ID", '<>%1', '');
//                     // pJobPlanningLine.SetRange("To Be Sent To Blade", true);
//                     // pJobPlanningLine.ModifyAll("Available Qty.", decBladeAvailableQty);
//                     pJobPlanningLine := JobPlanningLine;
//                     Commit();
//                     //Message('available qty in pjobplanningline is %1', pJobPlanningLine."Available Qty.");
//                     //Window.Update(1, BladeId);
//                 end;
//                 //Window.Close();
//             end;
//         end;
//     end;

//     procedure GetAvailableQtySalesOrder(var pSalesHeader: Record "Sales Header")//2202
//     var
//         lurl: Text;
//         TextJsonObject: JsonObject;
//         TextJsonArray: JsonArray;
//         TextJsonObjectValue: JsonValue;
//         //JobPlanningLine: Record "Job Planning Line";
//         //JobPlanningLineBuffer: record "Job Planning Line" temporary;
//         //Item:Record item;
//         SalesLine: Record "Sales Line";
//         intBladeItemId: Integer;
//         ltext: Text;
//         gcontent: HttpContent;
//         gheaders: HttpHeaders;
//         responseMsg: HttpResponseMessage;
//         lresptext: Text;
//         Client: HttpClient;
//         JsonToken: JsonToken;
//         i: Integer;
//         JsonTokentData: JsonToken;
//         BladeId: Text;
//         JsonTokenAvailable: JsonToken;
//         BladeAvailableQty: Text;
//         decBladeAvailableQty: Decimal;
//         Window: Dialog;
//         Text000: Label 'Updating the available qty. #1##########';
//     begin
//         Window.Open(Text000);
//         Authentication();
//         lurl := InventorySetup."Blade Base Url" + '/products/variations/stocks';
//         Clear(TextJsonObject);
//         Clear(TextJsonObjectValue);
//         Clear(TextJsonArray);
//         TextJsonObject.Add('product_variation_id', '');
//         //SetJobPlanningLineFiltersForMarkedToBeSent(JobPlanningLine, pJob);
//         SalesLine.Reset();
//         SalesLine.SetRange("Document Type", pSalesHeader."Document Type");
//         SalesLine.SetRange("Document No.", pSalesHeader."No.");
//         SalesLine.SetRange(Type, SalesLine.Type::Item);
//         SalesLine.SetFilter("Blade Item ID", '<>%1', '');
//         //SalesLine.SetRange("Whse. Outstanding Qty.",'');
//         if SalesLine.CalcFields("Whse. Outstanding Qty.") then
//             SalesLine.SetRange("Whse. Outstanding Qty.", 0);
//         if SalesLine.FindSet() then begin
//             repeat
//                 SalesLine.CalcFields("Blade Item ID");
//                 Evaluate(intBladeItemId, SalesLine."Blade Item ID");
//                 TextJsonObjectValue.SetValue(intBladeItemId);
//                 TextJsonArray.Add(TextJsonObjectValue);
//             until SalesLine.Next() = 0;
//         end;
//         TextJsonObject.Replace('product_variation_id', TextJsonArray);
//         TextJsonObject.Add('warehouse_code', 'CHR');
//         TextJsonObject.WriteTo(ltext);
//         gcontent.WriteFrom(ltext);
//         gcontent.ReadAs(ltext);
//         EntryNo := InsertLog(ltext, lurl);
//         gcontent.GetHeaders(gheaders);
//         gheaders.Remove('Content-Type');
//         gheaders.Add('Content-Type', 'application/json');
//         gheaders.Remove('Access-Token');
//         gheaders.Add('Access-Token', sessiontoken);
//         if Client.Put(lurl, gcontent, responseMsg) then begin
//             responseMsg.Content.ReadAs(lresptext);
//             ModifyLogwithResponse(lresptext, EntryNo);
//             Clear(TextJsonObject);
//             Clear(TextJsonArray);
//             JsonToken.ReadFrom(lresptext);
//             TextJsonObject := JsonToken.AsObject();
//             if TextJsonObject.Get('data', JsonToken) then begin
//                 TextJsonArray := JsonToken.AsArray();
//                 for i := 0 to TextJsonArray.Count - 1 do begin
//                     TextJsonArray.Get(i, JsonTokentData);
//                     TextJsonObject := JsonTokentData.AsObject();
//                     if TextJsonObject.Get('product_variation_id', JsonTokentData) then
//                         JsonTokentData.WriteTo(BladeId);
//                     if TextJsonObject.Get('available', JsonTokenAvailable) then
//                         JsonTokenAvailable.WriteTo(BladeAvailableQty);
//                     BladeId := DelChr(BladeId, '=', '"');
//                     BladeAvailableQty := DelChr(BladeAvailableQty, '=', '"');
//                     Evaluate(decBladeAvailableQty, BladeAvailableQty);
//                     SalesLine.Reset();
//                     SalesLine.SetRange("Document Type", pSalesHeader."Document Type");
//                     SalesLine.SetRange("Document No.", pSalesHeader."No.");
//                     SalesLine.SetRange("Blade Item ID", BladeId);
//                     SalesLine.SetRange("Whse. Outstanding Qty.", 0);
//                     SalesLine.ModifyAll("Available Qty.", decBladeAvailableQty);
//                     Window.Update(1, BladeId);
//                 end;
//                 Window.Close();
//             end;
//         end;
//     end;

//     procedure SplitJobPlanningLine(var pJobPlanningLine: record "Job Planning Line")
//     var
//         JobPlanningLine: record "job planning line";
//         RemainingQty: decimal;
//         JobJnlManagement: Codeunit JobJnlManagement;
//     begin
//         Clear(RemainingQty);
//         JobPlanningLine.init();
//         JobPlanningLine.TransferFields(pJobPlanningLine);
//         JobPlanningLine."Line No." := GetNextJobLineNo(pJobPlanningLine);
//         JobPlanningLine.ClearValues();
//         JobPlanningLine."Job Contract Entry No." := JobJnlManagement.GetNextEntryNo;
//         RemainingQty := Abs(pJobPlanningLine."Available Qty." - pJobPlanningLine."Qty. to Send to Blade");
//         Clear(JobPlanningLine.Quantity);
//         JobPlanningLine.Validate(Quantity, RemainingQty);
//         JobPlanningLine."Stock is Available" := false;
//         clear(JobPlanningLine."Available Qty.");
//         JobPlanningLine.Insert(true);
//         //JobPlanningLine.Modify();
//         //pJobPlanningLine.validate(pJobPlanningLine."Qty. to Send to Blade", pJobPlanningLine."Available Qty.");
//         //pJobPlanningLine."Qty. Sent to Blade" := pJobPlanningLine."Available Qty."
//         pJobPlanningLine."Qty. to Send to Blade" := pJobPlanningLine."Available Qty.";
//         pJobPlanningLine.Validate(Quantity, pJobPlanningLine."Available Qty." + pJobPlanningLine."Qty. Posted");
//         pJobPlanningLine."Stock is Available" := true;
//         pJobPlanningLine.Modify();
//     end;

//     procedure SplitSalesOrderline(var pSalesLine: record "Sales Line")//var removed//2202  
//     var
//         //JobPlanningLine: record "job planning line";
//         SalesLine: Record "Sales Line";
//         RemainingQty: decimal;
//         JobJnlManagement: Codeunit JobJnlManagement;
//     begin
//         Clear(RemainingQty);
//         SalesLine.Init();
//         SalesLine.TransferFields(pSalesLine);
//         SalesLine."Line No." := GetNextSalesLineNo(pSalesLine);
//         RemainingQty := Abs(pSalesLine."Available Qty." - pSalesLine.Quantity);
//         // JobPlanningLine.init();
//         // JobPlanningLine.TransferFields(pSalesLine);
//         //JobPlanningLine."Line No." := GetNextJobLineNo(pSalesLine);
//         // JobPlanningLine.ClearValues();
//         // JobPlanningLine."Job Contract Entry No." := JobJnlManagement.GetNextEntryNo;
//         // RemainingQty := Abs(pSalesLine."Available Qty." - pSalesLine."Qty. to Send to Blade");

//         //JobPlanningLine.Validate("Qty. to Send to Blade", RemainingQty);
//         //JobPlanningLine."Qty. to Send to Blade" := RemainingQty;

//         Clear(SalesLine.Quantity);
//         SalesLine.Validate(Quantity, RemainingQty);
//         SalesLine."Stock is Available" := false;
//         Clear(SalesLine."Available Qty.");
//         SalesLine.Insert(true);
//         //Clear(JobPlanningLine.Quantity);
//         //JobPlanningLine.Validate(Quantity, RemainingQty);
//         //JobPlanningLine.Insert(true);
//         //JobPlanningLine."Stock is Available" := false;
//         //clear(JobPlanningLine."Available Qty.");
//         //JobPlanningLine.Insert(true);
//         //JobPlanningLine.Modify();
//         //pJobPlanningLine.validate(pJobPlanningLine."Qty. to Send to Blade", pJobPlanningLine."Available Qty.");
//         //pJobPlanningLine."Qty. Sent to Blade" := pJobPlanningLine."Available Qty."
//         //pSalesLine."Qty. to Send to Blade" := pSalesLine."Available Qty.";
//         pSalesLine.Quantity := pSalesLine."Available Qty.";
//         //if (pJobPlanningLine."Remaining Qty." <> 0) then
//         //pJobPlanningLine.Validate(Quantity,pJobPlanningLine.qty);

//         //pSalesLine.Validate(Quantity, pSalesLine."Available Qty." + pSalesLine."Qty. Posted");

//         //pJobPlanningLine.Validate("Qty. to Send to Blade", pJobPlanningLine."Available Qty.");

//         pSalesLine."Stock is Available" := true;
//         pSalesLine.Modify();
//     end;

//     procedure CheckItemAvailabilityJob(var pJobPlanningLine: record "Job Planning Line")
//     var
//         Window: Dialog;
//         Text000: Label 'Splitting the lines #1##########';
//         OldJobPlanningLine: Record "Job Planning Line";
//         counter: Integer;
//     begin
//         //Window.Open(Text000);
//         clear(counter);
//         if pJobPlanningLine.FindFirst() then begin
//             Window.Open(Text000);
//             repeat
//                 counter += 1;
//                 OldJobPlanningLine.Copy(pJobPlanningLine);
//                 if (OldJobPlanningLine."Available Qty." <> 0) and (OldJobPlanningLine."Available Qty." < OldJobPlanningLine."Qty. to Send to Blade") then begin
//                     SplitJobPlanningLine(OldJobPlanningLine);
//                     Window.Update(1, OldJobPlanningLine."No.");
//                 end else begin
//                     if pJobPlanningLine."Available Qty." < pJobPlanningLine."Qty. to Send to Blade" then //begin                                                                                              //pJobPlanningLine."Stock is Available" := true;
//                         pJobPlanningLine."Stock is Available" := false
//                     else
//                         pJobPlanningLine."Stock is Available" := true;
//                     pJobPlanningLine.Modify();
//                 end;
//             until pJobPlanningLine.Next() = 0;
//             Window.Close();
//         end;
//     end;

//     procedure CheckItemAvailabilitySalesOrder(var pSalesHeader: record "sales header")//;var pSalesLine: record "Sales Line")//2202
//     var
//         Window: Dialog;
//         Text000: Label 'Splitting the lines #1##########';
//         //OldJobPlanningLine: Record "Job Planning Line";
//         CurrentSalesLine: Record "Sales Line";
//         OldSalesLine: Record "Sales Line";
//         counter: Integer;
//     begin
//         Window.Open(Text000);
//         clear(counter);
//         currentSalesLine.Reset();
//         currentSalesLine.SetRange("Document Type", pSalesHeader."Document Type");
//         currentSalesLine.SetRange("Document No.", pSalesHeader."No.");
//         CurrentSalesLine.SetRange(Type, CurrentSalesLine.Type::Item);
//         CurrentSalesLine.SetFilter("Blade Item ID", '<>%1', '');
//         if currentSalesLine.FindFirst() then begin
//             //Window.Open(Text000);
//             repeat
//                 counter += 1;
//                 OldSalesLine.Copy(CurrentSalesLine);
//                 if (OldSalesLine."Available Qty." <> 0) and (oldsalesline."Available Qty." < OldSalesLine.Quantity) then begin
//                     //if (pJobPlanningLine."Available Qty." <> 0) and (pJobPlanningLine."Available Qty." < pJobPlanningLine."Qty. to Send to Blade") then begin
//                     //OldJobPlanningLine.Copy(pJobPlanningLine);

//                     //SplitJobPlanningLine(OldJobPlanningLine);
//                     SplitSalesOrderline(OldSalesLine);
//                     //Message('old job line no is %1 and old item no is %2 and old stock is vailable is %3', OldJobPlanningLine."Line No.", OldJobPlanningLine."No.", OldJobPlanningLine."Stock is Available");
//                     Window.Update(1, OldSalesLine."No.");
//                 end else begin
//                     if CurrentSalesLine."Available Qty." < CurrentSalesLine.Quantity then                                                                                                    //pJobPlanningLine."Stock is Available" := true;
//                         CurrentSalesLine."Stock is Available" := false
//                     else
//                         CurrentSalesLine."Stock is Available" := true;
//                     CurrentSalesLine.Modify();
//                 end;
//             until CurrentSalesLine.Next() = 0;
//             Window.Close();
//         end;
//     end;

//     procedure SendAvailableJobPlanningLines(var pJobPlaningLine: Record "Job Planning Line")
//     var
//         OldJobPlanningLine: record "Job Planning Line";
//     begin
//         pJobPlaningLine.SetRange("Stock is Available", true);
//         if pJobPlaningLine.FindSet() then
//             CreateSalesOrderFromJob(pJobPlaningLine);
//     end;

//     procedure SendNonAvailableJobPlanningLines(var pJobPlanningLine: Record "Job Planning Line")
//     begin
//         pJobPlanningLine.SetRange("Stock is Available", false);
//         if pJobPlanningLine.FindSet() then
//             CreateSalesOrderFromJob(pJobPlanningLine);
//     end;

//     local procedure GetNextJobLineNo(FromJobPlanningLine: Record "Job Planning Line"): Integer
//     var
//         JobPlanningLine: Record "Job Planning Line";
//     begin
//         JobPlanningLine.SetRange("Job No.", FromJobPlanningLine."Job No.");
//         JobPlanningLine.SetRange("Job Task No.", FromJobPlanningLine."Job Task No.");
//         if JobPlanningLine.FindLast then;
//         exit(JobPlanningLine."Line No." + 10000);
//     end;

//     local procedure GetNextSalesLineNo(FromSalesLine: Record "Sales Line"): Integer
//     var
//         SalesLine: Record "Sales Line";
//     begin
//         SalesLine.SetRange("Document Type", FromSalesLine."Document Type");
//         SalesLine.SetRange("Document No.", FromSalesLine."Document No.");
//         if SalesLine.FindLast then;
//         exit(SalesLine."Line No." + 10000);
//     end;


//     local procedure ValidateBladeWhseShipmentStatus(BladeStatus: Text; var WhseShipmentHeader: Record "Warehouse Shipment Header")
//     begin
//         case BladeStatus of
//             'draft':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::draft);
//                 end;
//             'awaiting_allocation':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::awaiting_allocation);
//                 end;
//             'hung':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::hung);
//                 end;
//             'returned':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::returned);
//                 end;
//             'awaiting_payment':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::awaiting_payment);
//                 end;
//             'awaiting_picking':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::awaiting_picking);
//                 end;
//             'awaiting_despatch':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::awaiting_despatch);
//                 end;
//             'backorder_release':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::backorder_release);
//                 end;
//             'backorder':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::backorder);
//                 end;
//             'cancelled':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::cancelled);
//                 end;
//             'return_open':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::return_open);
//                 end;
//             'item_refunded':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::item_refunded);
//                 end;
//             'item_replaced':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::item_replaced);
//                 end;
//             'awaiting_collection':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::awaiting_collection);
//                 end;
//             'despatched':
//                 begin
//                     WhseShipmentHeader.Validate("Blade Status", WhseShipmentHeader."Blade Status"::despatched);
//                 end;
//         end;
//     end;

//     local procedure ValidateBladeJobLineStatus(BladeStatus: Text; var JobPlanningLine: Record "Job Planning Line")
//     begin
//         case BladeStatus of
//             'draft':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::draft);
//                 end;
//             'awaiting_allocation':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::awaiting_allocation);
//                 end;
//             'hung':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::hung);
//                 end;
//             'returned':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::returned);
//                 end;
//             'awaiting_payment':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::awaiting_payment);
//                 end;
//             'awaiting_picking':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::awaiting_picking);
//                 end;
//             'awaiting_despatch':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::awaiting_despatch);
//                 end;
//             'backorder_release':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::backorder_release);
//                 end;
//             'backorder':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::backorder);
//                 end;
//             'cancelled':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::cancelled);
//                 end;
//             'return_open':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::return_open);
//                 end;
//             'item_refunded':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::item_refunded);
//                 end;
//             'item_replaced':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::item_replaced);
//                 end;
//             'awaiting_collection':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::awaiting_collection);
//                 end;
//             'despatched':
//                 begin
//                     JobPlanningLine.Validate("Blade Status", JobPlanningLine."Blade Status"::despatched);
//                 end;
//         end;
//     end;

//     local procedure ValidateBladeWhseReceiptOrderStatus(BladeStatus: Text; var WarehouseReceiptHeader: Record "Warehouse Receipt Header")
//     begin
//         case BladeStatus of
//             'draft':
//                 begin
//                     WarehouseReceiptHeader.Validate("Blade Status", WarehouseReceiptHeader."Blade Status"::draft);
//                 end;
//             'cancelled':
//                 begin
//                     WarehouseReceiptHeader.Validate("Blade Status", WarehouseReceiptHeader."Blade Status"::cancelled);
//                 end;
//             'awaiting_approval':
//                 begin
//                     WarehouseReceiptHeader.Validate("Blade Status", WarehouseReceiptHeader."Blade Status"::awaiting_approval);
//                 end;
//             'awaiting_booking':
//                 begin
//                     WarehouseReceiptHeader.Validate("Blade Status", WarehouseReceiptHeader."Blade Status"::awaiting_booking);
//                 end;
//             'rejected':
//                 begin
//                     WarehouseReceiptHeader.Validate("Blade Status", WarehouseReceiptHeader."Blade Status"::rejected);
//                 end;
//             'open':
//                 begin
//                     WarehouseReceiptHeader.Validate("Blade Status", WarehouseReceiptHeader."Blade Status"::open);
//                 end;
//             'completed':
//                 begin
//                     WarehouseReceiptHeader.Validate("Blade Status", WarehouseReceiptHeader."Blade Status"::completed);
//                 end;
//             'discrepancies':
//                 begin
//                     WarehouseReceiptHeader.Validate("Blade Status", WarehouseReceiptHeader."Blade Status"::discrepancies);
//                 end;
//             'pending_completion':
//                 begin
//                     WarehouseReceiptHeader.Validate("Blade Status", WarehouseReceiptHeader."Blade Status"::pending_completion);
//                 end;

//         end;
//     end;

//     local procedure ValidateBladeWhseReceiptOrderLineStatus(BladeLineStatus: Text; var WarehouseReceiptLine: Record "Warehouse Receipt Line")
//     begin
//         case BladeLineStatus of
//             'awaiting_booking':
//                 begin
//                     WarehouseReceiptLine.Validate("Blade Line Status", WarehouseReceiptLine."Blade Line Status"::awaiting_booking);
//                 end;
//             'awaiting_shipping':
//                 begin
//                     WarehouseReceiptLine.Validate("blade line status", WarehouseReceiptLine."Blade Line Status"::awaiting_shipping);
//                 end;
//             'awaiting_receiving':
//                 begin
//                     WarehouseReceiptLine.Validate("Blade Line Status", WarehouseReceiptLine."Blade Line Status"::awaiting_receiving);
//                 end;
//             'awaiting_checkin':
//                 begin
//                     WarehouseReceiptLine.Validate("Blade Line Status", WarehouseReceiptLine."Blade Line Status"::awaiting_checkin);
//                 end;
//             'awaiting_putaway':
//                 begin
//                     WarehouseReceiptLine.Validate("Blade line Status", WarehouseReceiptLine."Blade line Status"::awaiting_putaway);
//                 end;
//             'completed':
//                 begin
//                     WarehouseReceiptLine.Validate("Blade Line Status", WarehouseReceiptLine."Blade line Status"::completed);
//                 end;
//             'cancelled':
//                 begin
//                     WarehouseReceiptLine.Validate("Blade line Status", WarehouseReceiptLine."Blade line Status"::cancelled);
//                 end;
//             'awaiting_collection':
//                 begin
//                     WarehouseReceiptLine.Validate("Blade line Status", WarehouseReceiptLine."Blade line Status"::awaiting_collection);
//                 end;
//         end;
//     end;

//     local procedure ValidateBladeItemStatus(BladeStatus: Text; var Item: Record Item)
//     begin
//         case BladeStatus of
//             'active':
//                 begin
//                     Item.Validate("Blade Status", Item."Blade Status"::active);
//                 end;
//             'draft':
//                 begin
//                     Item.Validate("Blade Status", Item."Blade Status"::draft);
//                 end;
//             'discontinued':
//                 begin
//                     Item.Validate("Blade Status", Item."Blade Status"::discontinued);
//                 end;
//         end;
//     end;

//     local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken
//     begin
//         if not JsonObject.Get(TokenKey, JsonToken) then
//             Error('Could not find a token with the key %1', TokenKey);
//     end;

//     local procedure SelectJsonToken(JsonObject: JsonObject; Path: Text) JsonToken: JsonToken
//     begin
//         if not JsonObject.SelectToken(Path, JsonToken) then
//             Error('Could not find a token with path %1', Path);
//     end;

//     procedure PostDespatchedWhseShipments()//0303
//     var
//         WarehouseShipmentHeader: Record "Warehouse Shipment Header";
//         WarehouseShipmentLine: Record "Warehouse Shipment Line";
//         WhsePostShipment: Codeunit "Whse.-Post Shipment";
//     begin
//         WarehouseShipmentHeader.Reset();
//         WarehouseShipmentHeader.SetRange("Blade Status", WarehouseShipmentHeader."Blade Status"::despatched);
//         if WarehouseShipmentHeader.FindSet() then begin
//             repeat
//                 WarehouseShipmentLine.Reset();
//                 WarehouseShipmentLine.SetRange("No.", WarehouseShipmentHeader."No.");
//                 if WarehouseShipmentLine.FindSet() then begin
//                     repeat
//                         WhsePostShipment.SetPostingSettings(false);
//                         WhsePostShipment.SetPrint(false);
//                         WhsePostShipment.Run(WarehouseShipmentLine);
//                         Clear(WhsePostShipment);
//                     until WarehouseShipmentLine.Next() = 0;
//                 end;
//             until WarehouseShipmentHeader.Next() = 0;
//         end;

//     end;

//     procedure PostDespatchedJobPlanningLines()
//     var
//         JobPlanningLine: Record "Job Planning Line";
//         JobTransferLine: Codeunit "Job Transfer Line";
//         JobJnlLine: Record "Job Journal Line";
//         JobJnlTemplate: Record "Job Journal Template";
//         JobJnlBatch: Record "Job Journal Batch";
//         LineCount: Integer;
//         StartLineNo: Integer;
//         JobJnlCheckLine: Codeunit "Job Jnl.-Check Line";
//         NoOfRecords: Integer;
//         JobLedgEntry: Record "Job Ledger Entry";
//         JobReg: Record "Job Register";
//         JobRegNo: Integer;
//         LastDocNo: Code[20];
//         LastDocNo2: Code[20];
//         LastPostedDocNo: Code[20];
//         NoSeriesMgt: Codeunit NoSeriesManagement;
//         NoSeriesMgt2: array[10] of Codeunit NoSeriesManagement;
//         NoSeries: Record "No. Series" temporary;
//         NoOfPostingNoSeries: Integer;
//         PostingNoSeriesNo: Integer;
//         Text006: Label 'A maximum of %1 posting number series can be used in each journal.';
//         JobJnlPostLine: Codeunit "Job Jnl.-Post Line";
//         InvtSetup: Record "Inventory Setup";
//         InvtAdjmt: Codeunit "Inventory Adjustment";
//     begin
//         InventorySetup.Get();
//         JobPlanningLine.Reset();//added
//         SetJobPlanningLineFiltersUpdateStatus(JobPlanningLine);
//         JobPlanningLine.SetRange("Blade Status", JobPlanningLine."Blade Status"::despatched);
//         JobPlanningLine.SetFilter("Remaining Qty.", '<>%1', 0);
//         if JobPlanningLine.FindSet() then begin
//             repeat
//                 JobTransferLine.FromPlanningLineToJnlLine(JobPlanningLine, WorkDate(), InventorySetup."Default Job Jnl Template", InventorySetup."Default Job Jnl Batch", JobJnlLine);
//             until JobPlanningLine.Next() = 0;
//             CODEUNIT.Run(CODEUNIT::"Job Jnl.-Post Batch", JobJnlLine); //test the lines on the job journal
//         end;
//     end;

//     procedure PostCompletedWhseReceipts()
//     var
//         WarehouseReceiptHeader: Record "Warehouse Receipt Header";
//         WarehouseReceiptLine: Record "Warehouse Receipt Line";
//         WhsePostReceipt: Codeunit "Whse.-Post Receipt";
//     begin
//         WarehouseReceiptHeader.Reset();
//         WarehouseReceiptHeader.SetRange("Blade Status", WarehouseReceiptHeader."Blade Status"::completed);
//         if WarehouseReceiptHeader.FindSet() then begin
//             repeat
//                 WarehouseReceiptLine.Reset();
//                 WarehouseReceiptLine.SetRange("No.", WarehouseReceiptHeader."No.");
//                 if WarehouseReceiptLine.FindSet() then begin
//                     repeat
//                         if (WarehouseReceiptLine.Quantity = WarehouseReceiptLine."Qty. to Receive") then begin
//                             WhsePostReceipt.Run(WarehouseReceiptLine);
//                             Clear(WhsePostReceipt);
//                         end;
//                     until WarehouseReceiptLine.Next() = 0;
//                 end;
//             until WarehouseReceiptHeader.Next() = 0;
//         end;
//     end;

//     procedure InsertLog(Logtext: Text; RequestUrl: Text): Integer
//     var
//         outstream: OutStream;
//         APIReqLogEntry: Record "Blade API Log Entry";
//         EntryNo: Integer;
//     begin
//         if APIReqLogEntry.FindLast() then
//             EntryNo := APIReqLogEntry."Entry No." + 1
//         else
//             EntryNo := 1;
//         APIReqLogEntry.Init();
//         APIReqLogEntry."Entry No." := EntryNo;
//         APIReqLogEntry."API Request Body".CreateOutStream(outstream);
//         outstream.WriteText(Logtext);
//         APIReqLogEntry."Request API URL" := RequestUrl;
//         APIReqLogEntry."Requested Date" := Today;
//         APIReqLogEntry."Requested Time" := Time;
//         APIReqLogEntry."User ID" := UserId;
//         APIReqLogEntry.Insert();
//         Commit();
//         exit(EntryNo);
//     end;

//     procedure ModifyLogwithResponse(ResponseMsg: Text; EntryNo: integer)
//     var
//         APIRequestLogEntry: Record "Blade API Log Entry";
//         outstream: OutStream;
//     begin
//         if APIRequestLogEntry.Get(EntryNo) then begin
//             APIRequestLogEntry."API Response Body".CreateOutStream(outstream);
//             outstream.WriteText(ResponseMsg);
//             APIRequestLogEntry.Modify();
//         end;

//     end;

//     procedure BladeFieldsEditable(pUserID: Code[50]): Boolean
//     var
//         UserSetup: Record "User Setup";
//     begin
//         if not UserSetup.Get(pUserID) then
//             exit;
//         exit(UserSetup."Allow Edit Blade");
//     end;

//     procedure SetJobPlanningLineFiltersUpdateStatus(var pJobPlanningLine: Record "Job Planning Line")
//     begin
//         pJobPlanningLine.Reset();
//         //pJobPlanningLine.SetFilter(Status, '%1|%2', pJobPlanningLine.Status::Order, pJobPlanningLine.Status::Planning);
//         pJobPlanningLine.SetFilter(Status, '<>%1', pJobPlanningLine.Status::Quote);
//         pJobPlanningLine.SetRange(Type, pJobPlanningLine.Type::Item);
//         pJobPlanningLine.SetFilter("Blade ID", '<>%1', '');
//         pJobPlanningLine.SetRange("Sent to Blade", true);
//         //pJobPlanningLine.SetFilter("Blade Status",'<>%1',pJobPlanningLine."Blade Status"::despatched);
//     end;

//     procedure SetJobPlanningLineFiltersForMarkedToBeSent(var pJobPlanningLine: Record "Job Planning Line"; pJob: record Job)
//     begin
//         pJobPlanningLine.Reset();
//         pJobPlanningLine.SetRange("Job No.", pJob."No.");
//         pJobPlanningLine.SetRange(Type, pJobPlanningLine.Type::Item);
//         pJobPlanningLine.SetFilter("Blade Item ID", '<>%1', '');
//         pJobPlanningLine.SetRange("To Be Sent To Blade", true);
//     end;

//     [EventSubscriber(ObjectType::Report, report::"Get Source Documents", 'OnBeforeWhseReceiptHeaderInsert', '', true, true)]
//     procedure InsertPurchaseOrderNo(var WarehouseReceiptHeader: Record "Warehouse Receipt Header"; var WarehouseRequest: Record "Warehouse Request")
//     begin
//         WarehouseReceiptHeader."Purchase Order No." := WarehouseRequest."Source No.";
//     end;

//     [EventSubscriber(ObjectType::Report, report::"Get Source Documents", 'OnBeforeWhseShptHeaderInsert', '', true, true)]
//     local procedure InsertSalesOrderNo(var WarehouseShipmentHeader: Record "Warehouse Shipment Header"; var WarehouseRequest: Record "Warehouse Request")
//     begin
//         WarehouseShipmentHeader."Sales Order No." := WarehouseRequest."Source No.";
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Warehouse Shipment Line", 'OnBeforeDeleteEvent', '', true, true)]
//     procedure CheckStatusWhseShipmentLine(var Rec: Record "Warehouse Shipment Line"; RunTrigger: Boolean)
//     var
//         WhseShipmentHeader: Record "Warehouse Shipment Header";
//         CancelWhseShipmentLineConfirm: Label 'Do you want to cancel the warehouse line in Blade?';
//         DespatchedErr: Label 'You cannot delete Warehouse Shipment No. %1 because it has already been despatched';
//         ShipLineDeleteErr: label 'You cannot delete the Shipment Line, the current status is %1.Please,cancel it using the function "Cancel Shipment Line".';
//     begin
//         WhseShipmentHeader.Get(Rec."No.");
//         if WhseShipmentHeader."Create Posted Header" then
//             exit;
//         if WhseShipmentHeader."Blade Status" = WhseShipmentHeader."Blade Status"::despatched then
//             Error(DespatchedErr, Rec."No.");
//         if (WhseShipmentHeader."Blade Status" <> WhseShipmentHeader."Blade Status"::cancelled) and (Rec."Blade Line Status" = Rec."Blade Line Status"::active) then //and rec."Sent to Blade" then
//             Error(ShipLineDeleteErr, Rec."Blade Line Status");
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Warehouse Shipment Header", 'OnBeforeDeleteEvent', '', true, true)]
//     procedure CheckStatusWhseShipmentHeader(var Rec: Record "Warehouse Shipment Header")
//     var
//         DespatchedErr: label 'You cannot delete Warehouse Shipment No. %1 because it has already been despatched';
//         ShipHeaderDeleteErr: Label 'You cannot delete the Shipment, the current status is %1.Please,cancel it using the function "Cancel Shipment".';
//     begin
//         if Rec."Create Posted Header" then
//             exit;

//         if Rec."Blade Status" = Rec."Blade Status"::despatched then
//             Error(DespatchedErr, Rec."No.");
//         if (rec."Blade Status" <> rec."Blade Status"::cancelled) and rec."Sent to Blade" then
//             Error(ShipHeaderDeleteErr, Rec."Blade Status");
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Warehouse Receipt Line", 'OnBeforeDeleteEvent', '', true, true)]
//     procedure CheckStatusWhseReceiptLine(var Rec: Record "Warehouse Receipt Line"; RunTrigger: Boolean)
//     var
//         WhseReceiptHeader: Record "Warehouse Receipt Header";
//         CancelWhseReceiptLineConfirm: Label 'Do you want to cancel the warehouse line in Blade?';
//         CompletedErr: Label 'You cannot delete Warehouse Receipt No. %1 because it has already been completed.';
//         ShipLineDeleteErr: label 'You cannot delete the Receipt Line, the current status is %1.Please,cancel it in Blade and use the function "Get Blade Status" to synchronize the Receipt Status.';
//     begin
//         WhseReceiptHeader.Get(Rec."No.");
//         if WhseReceiptHeader."Create Posted Header" then
//             exit;
//         if (WhseReceiptHeader."Blade Status" = WhseReceiptHeader."Blade Status"::completed) then
//             Error(CompletedErr, Rec."No.");
//         if (WhseReceiptHeader."Blade Status" <> WhseReceiptHeader."Blade Status"::cancelled) and (WhseReceiptHeader."Blade Status" <> WhseReceiptHeader."Blade Status"::Empty) then
//             Error(ShipLineDeleteErr, WhseReceiptHeader."Blade Status");
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Warehouse Receipt Header", 'OnBeforeDeleteEvent', '', true, true)]
//     procedure CheckStatusWhseReceiptHeader(var Rec: Record "Warehouse Receipt Header");
//     var
//         CompletedErr: label 'You cannot delete Warehouse Receipt No. %1 because it has already been completed.';
//         ReceiptHeaderDeleteErr: Label 'You cannot delete the Receipt, the current status is %1.Please,cancel it in Blade and use the function "Get Blade Status" to synchronize the Receipt Status.';
//     begin
//         if Rec."Create Posted Header" then
//             exit;
//         if Rec."Blade Status" = Rec."Blade Status"::completed then
//             Error(CompletedErr, Rec."No.");
//         if (Rec."Blade Status" <> Rec."Blade Status"::cancelled) and Rec."Sent to Blade" then
//             Error(ReceiptHeaderDeleteErr, Rec."Blade Status");
//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterValidateEvent', 'Quantity', true, true)]
//     procedure ValidateQtyToSendToBlade(CurrFieldNo: Integer; var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line")
//     var
//         UpdateQtyinBladeConfirm: Label 'The Job Planing Line has already been sent to Blade.Do you want to update the quantity for the Item No. %1 with Blade Reference No. %2? ?';
//         ChangeQtyDespatchedErr: Label 'You cannot change the Qty, because the job planning line has already been despatched';
//         ChangeQtyErr: Label 'You cannot change the quantity, because the job planning line has already been sent to Blade.';
//     begin
//         if (xRec.Quantity <> Rec.Quantity) then //and (xRec.Quantity <> 0) then
//             if (Rec."Blade Status" = Rec."Blade Status"::despatched) or (rec."Blade Status" = rec."Blade Status"::awaiting_despatch) then
//                 Error(ChangeQtyDespatchedErr);
//         if (xRec.Quantity <> rec.Quantity) and (not rec."Sent to Blade") and (Rec.Type = rec.Type::Item) then
//             Rec.validate("Qty. to Send to Blade", Rec."Remaining Qty.");
//         if (Rec."Sent to Blade") and (xRec.Quantity <> rec.Quantity) and (Rec."Blade Status" <> Rec."Blade Status"::cancelled) then begin
//             if not Confirm(UpdateQtyinBladeConfirm, false, Rec."No.", Rec."Blade Reference") then
//                 Error(ChangeQtyErr);
//             if Rec."Usage Link" then
//                 Rec.Validate("Qty. to Send to Blade", Rec."Remaining Qty.");
//             UpdateJobPlannningLineQty(Rec);
//         end;

//     end;

//     [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnBeforeDeleteEvent', '', true, true)]
//     procedure CheckStatusJobPlanningLine(var Rec: Record "Job Planning Line")
//     var
//         JobOrderExistsErr: Label 'You cannot delete the job planning line the current status is %1. Please, cancel it using the function "Cancel Job Planning Line"';
//     begin
//         if (Rec."Sent to Blade" and rec."Line Sent to Blade") then
//             Error(JobOrderExistsErr, Rec."Blade Line Status");
//     end;

//     [EventSubscriber(ObjectType::page, page::"sales order", 'OnBeforeActionEvent', 'Create &Warehouse Shipment', true, true)]
//     procedure ClearWhseBackorderField(var Rec: Record "Sales Header")
//     begin
//         Rec."Whse. Backorder" := false;
//     end;

//     [EventSubscriber(ObjectType::report, Report::"Get Source Documents", 'OnAfterSkipWarehouseRequest', '', true, true)]
//     procedure Skiplines(SalesLine: Record "Sales Line"; var SkipLine: Boolean)
//     var
//         SalesHeader: Record "Sales Header";
//     begin
//         SalesHeader.get(SalesLine."Document Type", SalesLine."Document No.");
//         if not SalesHeader."Whse. Backorder" then
//             SkipLine := not SalesLine."Stock is Available"
//         else
//             SkipLine := SalesLine."Stock is Available";
//     end;

//     var
//         RequestLine: Text;
//         sessiontoken: Text;
//         InventorySetup: Record "Inventory Setup";
//         CompanyInfo: Record "Company Information";
//         HideDialog: Boolean;
//         EntryNo: Integer;
//         ItemAttributeDictionary: Dictionary of [Text, Text];
//         GLSetup: Record "General Ledger Setup";
//         //client: HttpClient;
//         LastLineNo: Integer;
//         StockDifference: Decimal;
//         DocumentNo: Code[20];
//         OrderChannelDictionary: Dictionary of [Integer, Text];
//         ExpiryDateTime: DateTime;
//         NumberOfPages: Integer;
// }