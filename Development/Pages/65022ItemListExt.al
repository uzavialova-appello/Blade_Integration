pageextension 65022 "Blade Item List Ext." extends "Item List"
{
    actions
    {
        addlast(processing)
        {
            group("Blade Functions")
            {
                Image = Interaction;
                action("Get Blade Items")
                {
                    ApplicationArea = All;
                    Image = GetEntries;

                    trigger OnAction()
                    var
                        BladeMgt: Codeunit "Blade Mgt.";
                    begin
                        BladeMgt.GetBladeItems();
                    end;
                }
                // action("Update Item Blade Info")
                // {
                //     ApplicationArea = All;

                //     trigger OnAction()

                //     var
                //         DocumentNo: Code[20];
                //         NoSeriesMgt: Codeunit NoSeriesManagement;
                //         ItemJnlTemplate: Record "Item Journal Template";
                //         ItemJnlBatch: Record "Item Journal Batch";
                //         UpdateItemBladeInfoXml: XmlPort "Update Item Blade Info";
                //     begin
                //         ItemJnlTemplate.Get('ITEM');
                //         ItemJnlBatch.Get('ITEM', 'DEFAULT');
                //         if ItemJnlBatch."No. Series" <> '' then begin
                //             Clear(NoSeriesMgt);
                //             DocumentNo := NoSeriesMgt.TryGetNextNo(ItemJnlBatch."No. Series", WorkDate());
                //         end;
                //         FileName := 'C:\Update Item Blade Info.txt';
                //         UpdateItemBladeInfoXml.GetDocumentNo(DocumentNo);
                //         UpdateItemBladeInfoXml.Run();
                //     end;
                // }
            }
        }
    }
    var
        FileName: Text;
        FileInStream: InStream;
}