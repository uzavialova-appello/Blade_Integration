tableextension 65011 "Warehouse Shipment Line Blade" extends "Warehouse Shipment Line"
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
        //field(65002; "Blade Line Status"; enum "Blade Sales Line Status")
        field(65002; "Blade Line Status"; Enum "Blade Whse Shipment Line Status")
        {
            DataClassification = ToBeClassified;
        }
        field(65003; "Cancel Reason Code"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(65004; "Blade Sku"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(65005; "Qty. Sent to Blade"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
    }
}