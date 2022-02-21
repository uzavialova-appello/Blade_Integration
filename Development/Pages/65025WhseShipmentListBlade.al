pageextension 65025 "Whse. Shiment List Blade" extends "Warehouse Shipment List"
{
    actions
    {
        addlast(processing)
        {
            group("Blade Functions")
            {
                Image = Interaction;
                action("Get Whse Shipment Status")
                {
                    ApplicationArea = All;
                    Image = GetEntries;

                    trigger OnAction()
                    var
                        BladeMgt: Codeunit "Blade Mgt.";
                    begin
                        BladeMgt.GetWhseShipmentStatuses(false);
                    end;
                }
            }
        }
    }
}