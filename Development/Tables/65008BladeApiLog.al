table 65008 "Blade API Log Entry"
{
    LookupPageId = "Blade Api Log Entries";
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';

        }
        field(2; "Request API URL"; text[250])
        {
            Caption = 'Request API URL';
        }
        field(3; "API Request Body"; Blob)
        {
            Caption = 'API Request Body';
        }
        field(4; "Requested Date"; Date)
        {
            Caption = 'Requested Date';
        }
        field(5; "Requested Time"; Time)
        {
            Caption = 'Requested Time';
        }
        field(6; "User ID"; Code[50])
        {

        }
        field(7; "API Response Body"; Blob)
        {

        }

    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

}