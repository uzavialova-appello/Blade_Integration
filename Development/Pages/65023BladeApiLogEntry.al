page 65023 "Blade Api Log Entries"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = "Blade API Log Entry";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; rec."Entry No.")
                {
                    ApplicationArea = All;

                }
                field("Request API URL"; rec."Request API URL")
                {
                    ApplicationArea = all;
                }
                field("API Request Body"; RequestBody)
                {
                    ApplicationArea = all;
                }
                field("Requested Date"; rec."Requested Date")
                {
                    ApplicationArea = all;
                }
                field("Requested Time"; rec."Requested Time")
                {
                    ApplicationArea = all;
                }
                field("API Response Body"; ResponseBody)
                {
                    ApplicationArea = all;
                }

            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        RequestBody := GetAPIReqDescription();
        ResponseBody := GetAPIResponseDescription();
    end;

    procedure GetAPIReqDescription(): Text
    begin
        CALCFIELDS("API Request Body");
        EXIT(GetAPIReqDescriptionWorkDescriptionCalculated);
    end;

    procedure GetAPIReqDescriptionWorkDescriptionCalculated(): Text
    var
        inStream: InStream;
        result: Text;
    begin
        IF NOT "API Request Body".HASVALUE THEN
            EXIT('');

        "API Request Body".CreateInStream(inStream);
        inStream.ReadText(result);
        EXIT(result);
    end;

    procedure GetAPIResponseDescription(): Text
    begin
        CALCFIELDS("API Response Body");
        EXIT(GetAPIResponseDescriptionWorkDescriptionCalculated);
    end;

    procedure GetAPIResponseDescriptionWorkDescriptionCalculated(): Text
    var
        inStream: InStream;
        result: Text;
    begin
        IF NOT "API Response Body".HASVALUE THEN
            EXIT('');

        "API Response Body".CreateInStream(inStream);
        inStream.ReadText(result);
        EXIT(result);
    end;

    var
        RequestBody: Text;
        ResponseBody: Text;
}