pageextension 65029 "Blade Item Journal" extends "Item Journal"
{
    actions
    {
        addlast(processing)
        {
            group("Blade Functions")
            {
                Image = Interaction;
                action("Get Bulk Stock Differences")
                {
                    ApplicationArea = All;
                    Image = GetEntries;

                    trigger OnAction()
                    var
                        BladeMgt: Codeunit "Blade Mgt.";
                    begin
                        BladeMgt.GetBulkItemStock(Rec);
                        Commit();
                    end;
                }
            }
        }
    }
}