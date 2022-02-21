tableextension 65007 "Item Blade Ext." extends Item
{
    fields
    {
        field(65000; "Blade Item ID"; code[30])
        {
            DataClassification = ToBeClassified;
            Caption = 'Blade Variation ID';
        }
        field(65001; "Sent to Blade"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(65002; "Blade Status"; Enum "Blade Item Status")
        {
            DataClassification = ToBeClassified;
        }
        field(65003; "Blade Sku"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        // field(65004; "Blade Product ID"; Code[30])
        // {
        //     DataClassification = ToBeClassified;
        // }
    }
    keys
    {
        key(Key18; "Blade Item ID")
        {
        }
    }
}