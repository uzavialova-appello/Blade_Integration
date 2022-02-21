pageextension 65026 "Warehouse Receipt Order Blade" extends "Warehouse Receipt"
{
    layout
    {
        addlast(content)
        {
            group("Blade Integration")
            {
                Editable = AllowEditBladeFields;
                field("Blade ID"; "Blade ID")
                {
                    ApplicationArea = all;
                }
                field("Blade Status"; "Blade Status")
                {
                    ApplicationArea = all;
                }
                field("Sent to Blade"; "Sent to Blade")
                {
                    ApplicationArea = all;
                }
                field("Blade Reference";"Blade Reference")
                {
                    ApplicationArea = all;
                }
            }
        }
        addlast(General)
        {
            field("Purchase Order No."; "Purchase Order No.")
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
                action("Send Receipt")
                {
                    ApplicationArea = All;
                    Image = SendTo;

                    trigger OnAction()
                    var
                        DuplicateErr: Label 'You cannot send the warehouse receipt, because it has already been sent to Blade.';
                    begin
                        if Rec."Sent to Blade" and (rec."Blade ID" <> '') then begin
                            BladeMgt.SynchWarehouseReceiptStatus(Rec);
                            Commit();
                            if Rec."Blade Status" = Rec."Blade Status"::cancelled then
                                BladeMgt.CreateWarehouseReceiptOrder(Rec)
                            else
                                Error(DuplicateErr);
                        end else
                            BladeMgt.CreateWarehouseReceiptOrder(Rec);
                    end;
                }
                action("Get Blade Status")
                {
                    ApplicationArea = All;
                    Image = Status;

                    trigger OnAction()
                    begin
                        BladeMgt.SynchWarehouseReceiptStatus(Rec);
                    end;
                }
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

}