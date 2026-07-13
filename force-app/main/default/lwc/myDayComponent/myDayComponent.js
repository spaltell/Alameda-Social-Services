import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getTodaysVisits from '@salesforce/apex/MyDayController.getTodaysVisits';
import { refreshApex } from '@salesforce/apex';

export default class MyDayComponent extends NavigationMixin(LightningElement) {
    userId = Id;
    visitsData;
    visits;
    error;
    isLoading = true;

    @wire(getTodaysVisits, { userId: '$userId' })
    wiredVisits(result) {
        this.visitsData = result;
        this.isLoading = true;
        if (result.data) {
            this.visits = result.data;
            this.error = undefined;
            this.isLoading = false;
        } else if (result.error) {
            this.error = result.error;
            this.visits = undefined;
            this.isLoading = false;
        }
    }

    get hasVisits() {
        return this.visits && this.visits.length > 0;
    }

    get scheduledCount() {
        if (!this.visits) return 0;
        return this.visits.filter(v => v.householdVisitStatus === 'Scheduled').length;
    }

    get inProgressCount() {
        if (!this.visits) return 0;
        return this.visits.filter(v => v.householdVisitStatus === 'Visit In Progress').length;
    }

    get pendingCount() {
        if (!this.visits) return 0;
        return this.visits.filter(v => v.householdVisitStatus === 'Documentation Pending').length;
    }

    handleRefresh() {
        this.isLoading = true;
        refreshApex(this.visitsData);
    }

    handleStartVisit(event) {
        const visitId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: visitId,
                objectApiName: 'Visit',
                actionName: 'view'
            }
        });
    }

    handleGetDirections(event) {
        const address = event.currentTarget.dataset.address;
        if (address) {
            const mapsUrl = `https://www.google.com/maps/dir/?api=1&destination=${encodeURIComponent(address)}`;
            window.open(mapsUrl, '_blank');
        }
    }

    handleViewAccount(event) {
        const accountId = event.currentTarget.dataset.accountid;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}