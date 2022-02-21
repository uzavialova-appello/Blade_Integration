codeunit 65003 "Post Completed Blade Orders"
{
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        case "Parameter String" of
            'Job_Planning_Lines':
                PostJobPlanningLines();
            'Warehouse_Shipments':
                PostWhseShipments();
            'Warehouse_Receipts':
                PostWhseReceipts();
        end;
    end;

    procedure PostWhseShipments()
    begin
        BladeMgt.PostDespatchedWhseShipments();
    end;

    procedure PostWhseReceipts()
    begin
        BladeMgt.PostCompletedWhseReceipts();
    end;

    procedure PostJobPlanningLines()
    begin
        BladeMgt.PostDespatchedJobPlanningLines();
    end;

    var
        BladeMgt: Codeunit "Blade Mgt.";
}