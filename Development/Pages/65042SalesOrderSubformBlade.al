pageextension 65042 "Sales Order Subform Blade" extends "Sales Order Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field("Available Qty."; "Available Qty.")
            {
                ApplicationArea = all;
            }
            field("Blade Item ID"; "Blade Item ID")
            {
                ApplicationArea = all;
            }
            field("Stock is Available"; "Stock is Available")
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
    }  
}