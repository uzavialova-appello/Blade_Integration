tableextension 65009 "Whse Shipment Blade" extends "Warehouse Shipment Header"
{
    fields
    {
        field(65000; "Blade ID"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        //field(65001; "Blade Status"; Enum "Blade Sales Order Status")
        field(65001; "Blade Status"; Enum "Blade Whse Shipment Status")
        {
            DataClassification = ToBeClassified;
        }
        field(65002; "Sent to Blade"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(65003; "Sales Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(65004; "Reason Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Reason Code";
        }
    }
    keys
    {
        key(Key13; "Blade ID", "Blade Status", "Sent to Blade")
        {
        }
    }
}