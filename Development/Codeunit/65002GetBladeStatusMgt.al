codeunit 65002 "Get Blade Statuses"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        case "Parameter String" of
            'Job_Planning_Lines':
                GetBladeJobPlannningLineStatus();
            'Warehouse_Shipments':
                GetBladeWhseShipmentStatus();
            'Warehouse_Receipts':
                GetBladeWhseReceiptStatus();

        end;
    end;

    procedure GetBladeJobPlannningLineStatus()
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.Reset();
        BladeMgt.SetJobPlanningLineFiltersUpdateStatus(JobPlanningLine);
        //JobPlanningLine.SetFilter(JobPlanningLine."Blade Status", '<>%1', JobPlanningLine."Blade Status"::despatched);
        JobPlanningLine.SetFilter(JobPlanningLine."Remaining Qty.", '<>%1', 0);
        if not JobPlanningLine.FindSet() then
            exit;

        BladeMgt.GetJobPlanningLineStatuses(JobPlanningLine, true);
    end;

    procedure GetBladeWhseShipmentStatus()
    begin
        BladeMgt.GetWhseShipmentStatuses(true);
    end;

    procedure GetBladeWhseReceiptStatus()
    var
        WhseReceiptHeader: Record "Warehouse Receipt Header";
    begin
        WhseReceiptHeader.Reset();
        WhseReceiptHeader.SetFilter("Blade ID", '<>%1', '');
        WhseReceiptHeader.SetRange("Sent to Blade", true);
        if WhseReceiptHeader.FindFirst() then begin
            repeat
                BladeMgt.SynchWarehouseReceiptStatus(WhseReceiptHeader);
            until WhseReceiptHeader.Next() = 0;
        end;
    end;

    var
        BladeMgt: Codeunit "Blade Mgt.";
}