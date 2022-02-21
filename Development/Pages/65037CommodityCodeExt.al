pageextension 65037 "Commodity Codes Blade" extends "Tariff Numbers"
{
    layout
    {
        addlast(Control1)
        {
            field("Duty Rate"; "Duty Rate")
            {
                ApplicationArea = all;
            }
            field("Blade ID"; "Blade ID")
            {
                ApplicationArea = all;
                Editable = AllowEditBladeFields;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            group("Blade Functions")
            {
                Image = Interaction;
                action("Get Blade Commodity Codes")
                {
                    ApplicationArea = All;
                    Image = GetEntries;
                    trigger OnAction()
                    begin
                        BladeMgt.GetCommodityCodes();
                    end;
                }
                action("Send to Blade")
                {
                    ApplicationArea = All;
                    Image = SendTo;
                    trigger OnAction()
                    var
                        Text001:Label 'The Commodity No. %1 has already been sent to Blade.';
                    begin
                        if "Blade ID" <> '' then  
                           Error(Text001,"No.");
                        BladeMgt.CreateCommodityCode(Rec);
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