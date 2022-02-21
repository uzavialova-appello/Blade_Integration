tableextension 65013 "Warehouse Receipt Line Blade" extends "Warehouse Receipt Line"
{
    fields
    {
        field(65000; "Blade Line ID"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(65001; "Sent to Blade"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        //field(65002; "Blade Line Status"; enum "Blade Purch Order Line Status")
        field(65002; "Blade Line Status"; Enum "Blade Whse Receipt Line Status")
        {
            DataClassification = ToBeClassified;
        }
        field(65003; "Qty. Sent to Blade"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(65004; "Blade Sku"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(Key12; "Blade Sku", "Blade Line Status", "Sent to Blade", "Blade Line ID")
        {
        }
    }
}