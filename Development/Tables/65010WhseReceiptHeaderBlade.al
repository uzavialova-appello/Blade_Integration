tableextension 65010 "Warehouse Receipt Header Blade" extends "Warehouse Receipt Header"
{
    fields
    {
        field(65000; "Blade ID"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        //field(65001; "Blade Status"; Enum "Blade Purch Order Status")
        field(65001; "Blade Status"; Enum "Blade Whse Receipt Status")
        {
            DataClassification = ToBeClassified;
        }
        field(65002; "Sent to Blade"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(65003; "Purchase Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(65004; "Blade Reference"; Code[20])
        {
            DataClassification = ToBeClassified;
            //Editable = false;
        }
        // field(65005; "Blade GoodsIn Id"; Code[30])
        // {
        //     DataClassification = ToBeClassified;
        // }
        field(65005; "Post Whse Receipt Header"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(Key10; "Blade ID", "Blade Status", "Sent to Blade")
        {
        }
    }

}