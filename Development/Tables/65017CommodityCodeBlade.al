tableextension 65017 "Commodity Codes Blade" extends "Tariff Number"
{
    fields
    {
        field(65000; "Duty Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(65001; "Blade ID"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
    }
}