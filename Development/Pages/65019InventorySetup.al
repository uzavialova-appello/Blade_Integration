pageextension 65019 "Inventory Blade Info" extends "Inventory Setup"
{
    layout
    {
        addlast(content)
        {
            group("Blade Integration")
            {
                Editable = AllowEditBladeFields;
                field("Blade Base Url"; "Blade Base Url")
                {
                    ApplicationArea = all;
                }
                field("Blade Organization ID"; "Blade Organization ID")
                {
                    ApplicationArea = all;
                }
                field("Blade Login ID"; "Blade Login ID")
                {
                    ApplicationArea = all;
                }
                field("Blade Password"; "Blade Password")
                {
                    ApplicationArea = all;
                }
                field("Blade Brand ID "; "Blade Brand ID ")
                {
                    ApplicationArea = all;
                }
                field("Blade Order Channel ID "; "Blade Order Channel ID ")
                {
                    ApplicationArea = all;
                }
                field("Default Job Jnl Template"; "Default Job Jnl Template")
                {
                    ApplicationArea = all;
                }
                field("Default Job Jnl Batch"; "Default Job Jnl Batch")
                {
                    ApplicationArea = all;
                }
            }
        }

    }

    trigger OnAfterGetRecord()
    begin
        AllowEditBladeFields := BladeMgt.BladeFieldsEditable(UserId);
    end;

    var
        BladeMgt: Codeunit "Blade Mgt.";
        [InDataSet]
        AllowEditBladeFields: Boolean;
}