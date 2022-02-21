pageextension 65027 "Whse Shipment Subform Blade" extends "Whse. Shipment Subform"
{
    layout
    {
        modify("Qty. to Ship")
        {
            //Editable = false;
            Editable = AllowEditBladeFields;
            ToolTip = 'Qty. to Ship that has been processed in Blade.';
        }
        addlast(Control1)
        {
            field("Blade Line ID"; "Blade Line ID")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Sent to Blade"; "Sent to Blade")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Blade Line Status"; "Blade Line Status")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
            field("Cancel Reason Code"; "Cancel Reason Code")
            {
                ApplicationArea = all;
            }
            field("Qty. Sent to Blade"; "Qty. Sent to Blade")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }

        }
    }


    actions
    {
        addlast(processing)
        {
            group("Blade Functions")
            {
                Image = Interaction;
                action("Send New Line")
                {
                    ApplicationArea = All;
                    Image = SendTo;

                    trigger OnAction()
                    begin
                        if Rec."Sent to Blade" then
                            Error('You cannot send the Shipment line, because it has already been sent.');
                        WhseShipmentHeader.Get(Rec."No.");
                        WhseShipmentLine.get(Rec."No.", Rec."Line No.");
                        BladeMgt.AddWhseShipmentLine(WhseShipmentHeader, WhseShipmentLine);
                    end;
                }
                action("Cancel Shipment Line")
                {
                    ApplicationArea = All;
                    Image = Cancel;

                    trigger OnAction()
                    begin
                        if Rec."Blade Line Status" = Rec."Blade Line Status"::void then
                            Error('The warehouse Shipment Line is already cancelled.');
                        WhseShipmentHeader.Get(Rec."No.");
                        WhseShipmentLine.get(Rec."No.", Rec."Line No.");
                        BladeMgt.CancelWhseShipmentOrderLine(WhseShipmentHeader, WhseShipmentLine);
                    end;
                }
                action("Update Dummy Serial No.")
                {
                    ApplicationArea = All;
                    Visible = AllowEditBladeFields;

                    trigger OnAction()
                    begin
                        WhseShipmentHeader.Get(Rec."No.");
                        //BladeMgt.InsertSerialNos(Rec."Item No.", WhseShipmentHeader, Rec);
                    end;
                }
                // action("Update Shipment Line Quantity")
                // {
                //     ApplicationArea = All;
                //     Image = UpdateUnitCost;

                //     trigger OnAction()
                //     begin
                //         WhseShipmentHeader.Get(Rec."No.");
                //         WhseShipmentLine.get(Rec."No.", Rec."Line No.");
                //         BladeMgt.UpdateWhseShipmentLineQty(WhseShipmentHeader, WhseShipmentLine, SuppressMessage);
                //     end;
                // }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        AllowEditBladeFields := BladeMgt.BladeFieldsEditable(UserId);
    end;

    var
        BladeMgt: Codeunit "Blade Mgt.";
        [InDataSet]
        AllowEditBladeFields: Boolean;
        WhseShipmentHeader: Record "Warehouse Shipment Header";
        WhseShipmentLine: Record "Warehouse Shipment Line";
        SuppressMessage: Boolean;
}
