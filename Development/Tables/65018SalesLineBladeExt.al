tableextension 65018 "Sales Line Blade" extends "Sales Line"
{
    fields
    {
        field(65000; "Available Qty."; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            //Editable = false;
        }
        field(65001; "Blade Item ID"; code[30])
        {

            FieldClass = FlowField;
            CalcFormula = lookup(Item."Blade Item ID" where("No." = field("No."))); 
            Editable = false;
        }
        field(65002; "Stock is Available"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}