pageextension 65028 "Blade User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("Allow Edit Blade"; "Allow Edit Blade")
            {
                ApplicationArea = all;
            }
        }
    }
}