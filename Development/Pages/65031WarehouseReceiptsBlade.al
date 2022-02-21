pageextension 65031 "Warehouse Receipts Blade" extends "Warehouse Receipts"
{
    actions
    {
        addlast(processing)
        {
            group("Blade Functions")
            {
                Image = Interaction;
                // action("Get Blade Purchase Orders")
                // {
                //     ApplicationArea = All;
                //     Image = GetEntries;

                //     trigger OnAction()
                //     begin
                //         //BladeMgt.GetPurchaseOrders();
                //     end;
                // }
                action("Get Purchase Orders Status")
                {
                    ApplicationArea = All;
                    Image = Status;

                    trigger OnAction()
                    var
                        WhseReceiptHeader: Record "Warehouse Receipt Header";
                    begin
                        WhseReceiptHeader.Reset();
                        WhseReceiptHeader.SetFilter("Blade ID", '<>%1', '');
                        WhseReceiptHeader.SetRange("Sent to Blade", true);
                        if WhseReceiptHeader.FindFirst() then begin
                            repeat
                                BladeMgt.SynchWarehouseReceiptStatus(WhseReceiptHeader);
                            until WhseReceiptHeader.Next() = 0;
                        end;
                    end;
                }
            }
        }
    }

    var
        BladeMgt: Codeunit "Blade Mgt.";
}