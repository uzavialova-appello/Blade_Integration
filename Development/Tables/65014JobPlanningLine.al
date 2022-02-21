tableextension 65014 "Job Planning Line Blade" extends "Job Planning Line"
{
    fields
    {
        field(65010; "Blade Reference"; Code[20])
        {
            DataClassification = ToBeClassified;
            //Editable = false;
        }
        field(65011; "Blade ID"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(65012; "Blade Line ID"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(65013; "Sent to Blade"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Header Sent to Blade';
        }
        field(65014; "Qty. to Send to Blade"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            var
                DifferentQtyErr: Label 'You cannot send to Blade a different quantity than the Remaining Qty.';
                NotItemErr: Label 'Job Planning Line contains G/L Account No. %1. You can send only Items to Blade.';
            begin
                if Rec.Type <> Rec.Type::Item then
                    Error(NotItemErr, Rec."No.");
                if "Usage Link" then begin
                    if "Qty. to Send to Blade" <> "Remaining Qty." then
                        Error(DifferentQtyErr);
                end;
            end;
        }
        field(65015; "Qty. Sent to Blade"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;

        }
        field(65016; "Blade Status"; Enum "Blade Whse Shipment Status")
        {
            DataClassification = ToBeClassified;
        }
        field(65017; "Blade Line Status"; Enum "Blade Whse Shipment Line Status")
        {
            DataClassification = ToBeClassified;
        }
        field(65018; "Blade Cancel Reason"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(65019; "Line Sent to Blade"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(65020; "To Be Sent To Blade"; Boolean)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                DuplicateErr: Label 'The job planning line has already been sent under blade reference %1.';
                NotItemErr: Label 'You cannot select a G/L Account,only Items';
            begin
                if Rec.Type <> Rec.Type::Item then
                    Error(NotItemErr);
                if (not xRec."To Be Sent To Blade" and Rec."To Be Sent To Blade") then begin
                    if Rec."Sent to Blade" and (Rec."Blade Status" <> Rec."Blade Status"::cancelled) then
                        Error(DuplicateErr, Rec."Blade Reference");
                    TestField("Qty. to Send to Blade");
                end;
            end;
        }
        field(65021; "Blade Sku"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(65022; "Available Qty."; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            //Editable = false;
        }
        field(65023; "Blade Item ID"; code[30])
        {

            FieldClass = FlowField;
            CalcFormula = lookup(Item."Blade Item ID" where("No." = field("No.")));//,"No." = field("No.")));
            Editable = false;
        }
        field(65024; "Stock is Available"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(Key15; "Blade ID", "Blade Status", "Sent to Blade", "Blade Reference")
        {
        }
    }
}