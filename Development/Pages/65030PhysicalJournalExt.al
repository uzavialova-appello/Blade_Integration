pageextension 65030 "Blade Physical Inventory" extends "Phys. Inventory Journal"
{
    actions
    {
        addlast(processing)
        {
            group("Blade Functions")
            {
                Image = Interaction;
                action("Get Bulk Physical Stock")
                {
                    ApplicationArea = All;
                    Image = GetEntries;

                    trigger OnAction()
                    var
                        BladeMgt: Codeunit "Blade Mgt.";
                    begin
                        BladeMgt.GetBulkPhysicalStock(Rec);
                        Commit();
                    end;
                }
            }
        }
    }
}