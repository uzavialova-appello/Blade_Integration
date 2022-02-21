pageextension 65020 "Blade Item Card Ext." extends "Item Card"
{
    layout
    {
        addlast(content)
        {
            group("Blade Integration")
            {
                Editable = AllowEditBladeFields;

                field("Blade Item ID"; "Blade Item ID")
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
                field("Blade Sku"; "Blade Sku")
                {
                    ApplicationArea = all;
                }
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
                action("Send to Blade")
                {
                    ApplicationArea = All;
                    Image = SendTo;

                    trigger OnAction()
                    var
                        Text001: Label 'The Item No. %1 has already been sent to Blade.';
                    begin
                        if not "Sent to Blade" then
                            BladeMgt.AddItem(Rec)
                        else
                            Error(Text001, "No.");
                    end;
                }
                action("Activate Item in Blade")
                {
                    ApplicationArea = all;
                    Image = ValidateEmailLoggingSetup;
                    trigger OnAction()
                    begin
                        TestField("Blade Item ID");
                        BladeMgt.ActivateBladeProduct(Rec);
                    end;
                }
                action("Discontinue Item in Blade")
                {
                    ApplicationArea = All;
                    Image = CancelLine;

                    trigger OnAction()
                    begin
                        TestField("Blade Item ID");
                        BladeMgt.DiscontinueBladeProduct(Rec);
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