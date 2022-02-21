tableextension 65016 "Sales Header Blade" extends "Sales Header"
{
    fields
    {
        field(65000; "Delivery Instructions"; Text[75])
        {
            DataClassification = ToBeClassified;
        }
        field(65001; "Whse. Backorder"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}