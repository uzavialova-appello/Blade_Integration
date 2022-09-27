pageextension 65024 "Warehouse Shipment Order Blade" extends "Warehouse Shipment"
{
    layout
    {
        addlast(content)
        {
            group("Blade Integration")
            {
                field("Blade ID"; "Blade ID")
                {
                    ApplicationArea = all;
                    Editable = AllowEditBladeFields;
                }
                field("Blade Status"; "Blade Status")
                {
                    ApplicationArea = all;
                    Editable = AllowEditBladeFields;
                }
                field("Sent to Blade"; "Sent to Blade")
                {
                    ApplicationArea = all;
                    Editable = AllowEditBladeFields;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = all;
                    Caption = 'Cancel Reason Code';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

            }
        }
        addlast(General)
        {
            field("Sales Order No."; "Sales Order No.")
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
                action("Send Shipment")
                {
                    ApplicationArea = All;
                    Image = SendTo;

                    trigger OnAction()
                    begin
                        WhseShipmentHeader.Get(Rec."No.");
                        BladeMgt.CreateWhseShipmentOrder(WhseShipmentHeader);
                    end;
                }
                action("Cancel Shipment")
                {
                    ApplicationArea = All;
                    Image = Cancel;

                    trigger OnAction()
                    begin
                        WhseShipmentHeader.Get(Rec."No.");
                        BladeMgt.CancelWhseShipmentOrder(WhseShipmentHeader, false);
                    end;
                }
                action("Update Shipping Address")
                {
                    ApplicationArea = All;
                    Image = UpdateShipment;

                    trigger OnAction()
                    begin
                        WhseShipmentHeader.Get(Rec."No.");
                        BladeMgt.UpdateShippingAddress(WhseShipmentHeader);
                    end;
                }
                // action("Get Despatch Attributes")
                // {
                //     ApplicationArea = All;

                //     trigger OnAction()
                //     begin
                //         WhseShipmentHeader.Get(Rec."No.");
                //         BladeMgt.GetDespatchAttributes(WhseShipmentHeader);
                //     end;
                // }//temp removed 
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

}