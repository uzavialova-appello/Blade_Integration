tableextension 65006 "Inventory Blade Info" extends "Inventory Setup"
{
    fields
    {
        field(65000; "Blade Base Url"; Text[60])
        {
            Caption = 'Blade Base Url';
        }
        field(65001; "Blade Login ID"; Text[60])
        {
            Caption = 'Blade Login ID';
        }
        field(65002; "Blade Password"; Text[100])
        {
            Caption = 'Blade Password';
        }
        field(65003; "Blade Organization ID"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'Blade Item Channel ID';
        }
        field(65004; "Blade Brand ID "; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(65005; "Blade Order Channel ID "; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(65006; "Default Job Jnl Template"; code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Journal Template".Name WHERE("Page ID" = CONST(201),
                                                                       Recurring = CONST(false));
        }
        field(65007; "Default Job Jnl Batch"; code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Journal Batch".Name WHERE("Journal Template Name" = FIELD("Default Job Jnl Template"));
        }
    }
}