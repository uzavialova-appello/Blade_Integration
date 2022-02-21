pageextension 65039 "Sales Order Blade" extends "Sales Order"
{
    layout
    {
        addafter("Combine Shipments")
        {
            field("Delivery Instructions"; "Delivery Instructions")
            {
                ApplicationArea = all;
                MultiLine = true;
            }
            // field("Whse. Backorder"; "Whse. Backorder")
            // {
            //     ApplicationArea = all;
            // }
        }
    }
    actions
    {
        addlast(processing)
        {
            group("Blade Functions")
            {
                action("Get Available Qty.")
                {
                    ApplicationArea = All;
                    Image = GetEntries;

                    trigger OnAction()
                    var
                        Job: Record Job;
                    begin
                        //Job.Get(Rec."Job No.");
                        //BladeMgt.GetAvailableQtyJob(Job);
                        BladeMgt.GetAvailableQtySalesOrder(Rec);
                        BladeMgt.CheckItemAvailabilitySalesOrder(Rec);
                    end;
                }
            }
        }
        addafter("Create &Warehouse Shipment")
        {
            action("Create Whse Shipment Backorder")
            {
                AccessByPermission = TableData "Warehouse Shipment Header" = R;
                ApplicationArea = Warehouse;
                Caption = 'Create Whse Shipment Backorder';
                Image = NewShipment;
                ToolTip = 'Create a warehouse shipment to Send to Blade as Backorder.';

                trigger OnAction()
                var
                    GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
                    SalesHeader: Record "Sales Header";
                begin
                    //SalesHeader.get(rec."Document Type", Rec."No.");
                    //Rec."Whse. Backorder" := true;
                    //SalesHeader."Whse. Backorder" := true;
                    //salesModify();
                    Rec."Whse. Backorder" := true;
                    CurrPage.Update(true);
                    GetSourceDocOutbound.CreateFromSalesOrder(Rec);
                    //GetSourceDocOutbound.CreateFromSalesOrder(SalesHeader);
                    // if not Find('=><') then
                    //     Init;
                    //Rec."Whse. Backorder" := false;
                    //Clear(SalesHeader."Whse. Backorder");
                    //SalesHeader.Modify();
                    Rec."Whse. Backorder" := false;
                    Rec.Modify(false);
                    CurrPage.Update(true);
                    CurrPage.SaveRecord();
                end;
            }
        }
    }
    var
        BladeMgt: Codeunit "Blade Mgt.";

}