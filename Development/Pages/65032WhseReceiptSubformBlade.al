pageextension 65032 "Whse. Receipt Subform Blade" extends "Whse. Receipt Subform"
{
    layout
    {
        modify("Qty. to Receive")
        {
            Editable = AllowEditBladeFields;
            //ToolTip = 'Qty. to Receive that has been processed in Blade.';
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
            field("Qty. Sent to Blade"; "Qty. Sent to Blade")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
        }
    }


    // actions
    // {
    //     addlast(processing)
    //     {
    //         group("Blade Functions")
    //         {
    //             Image = Interaction;
    //             action("Send New Line")
    //             {
    //                 ApplicationArea = All;
    //                 Image = SendTo;

    //                 trigger OnAction()
    //                 var
    //                     SalesHeader: Record "Sales Header";
    //                 begin
    //                     SalesHeader.get(Rec."Document Type", Rec."Document No.");
    //                     BladeMgt.AddSalesOrderLine(SalesHeader."Blade ID", Rec);
    //                 end;
    //             }
    //             action("Cancel Order Line")
    //             {
    //                 ApplicationArea = All;
    //                 Image = Cancel;

    //                 trigger OnAction()
    //                 var
    //                     SalesHeader: Record "Sales Header";
    //                 begin
    //                     SalesHeader.get(Rec."Document Type", Rec."Document No.");
    //                     BladeMgt.CancelSalesOrderLine(SalesHeader."Blade ID", Rec);
    //                 end;
    //             }
    //         }
    //     }
    //}
    trigger OnAfterGetCurrRecord()
    begin
        AllowEditBladeFields := BladeMgt.BladeFieldsEditable(UserId);
    end;

    var
        BladeMgt: Codeunit "Blade Mgt.";
        [InDataSet]
        AllowEditBladeFields: Boolean;
}