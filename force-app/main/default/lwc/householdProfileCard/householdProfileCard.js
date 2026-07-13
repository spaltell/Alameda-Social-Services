import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getVisitHistory from '@salesforce/apex/HouseholdProfileController.getVisitHistory';
import { NavigationMixin } from 'lightning/navigation';

const ACCOUNT_FIELDS = ['Account.Name'];

export default class HouseholdProfileCard extends NavigationMixin(LightningElement) {
    @api recordId;

    visitHistory;
    error;
    isLoading = true;
    accountName;

    @wire(getRecord, { recordId: '$recordId', fields: ACCOUNT_FIELDS })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountName = data.fields.Name.value;
        } else if (error) {
            console.error('Error loading account:', error);
        }
    }

    @wire(getVisitHistory, { accountId: '$recordId' })
    wiredVisits({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.visitHistory = data;
            this.error = undefined;
            this.isLoading = false;
        } else if (error) {
            this.error = error;
            this.visitHistory = undefined;
            this.isLoading = false;
            console.error('Error loading visit history:', error);
        }
    }

    get hasVisits() {
        return this.visitHistory && this.visitHistory.recentVisits && this.visitHistory.recentVisits.length > 0;
    }

    get mostRecentVisit() {
        return this.hasVisits ? this.visitHistory.recentVisits[0] : null;
    }

    get riskLevelClass() {
        if (!this.mostRecentVisit || !this.mostRecentVisit.riskLevel) return '';
        const risk = this.mostRecentVisit.riskLevel.toLowerCase();
        return `slds-badge risk-${risk}`;
    }

    get showOverdueAlert() {
        return this.visitHistory && this.visitHistory.isOverdue;
    }

    get showPendingExceptionAlert() {
        return this.visitHistory && this.visitHistory.hasPendingExceptions;
    }

    get daysSinceLastVisit() {
        return this.visitHistory ? this.visitHistory.daysSinceLastVisit : null;
    }

    get formattedLastVisitDate() {
        if (this.mostRecentVisit && this.mostRecentVisit.completedDate) {
            return new Date(this.mostRecentVisit.completedDate).toLocaleDateString();
        }
        return 'No visits recorded';
    }

    get authorizedHours() {
        if (!this.mostRecentVisit) return [];

        const hours = [];
        if (this.mostRecentVisit.mealPrepHours) {
            hours.push({ label: 'Meal Preparation', value: this.mostRecentVisit.mealPrepHours });
        }
        if (this.mostRecentVisit.ambulationHours) {
            hours.push({ label: 'Ambulation', value: this.mostRecentVisit.ambulationHours });
        }
        if (this.mostRecentVisit.domesticServicesHours) {
            hours.push({ label: 'Domestic Services', value: this.mostRecentVisit.domesticServicesHours });
        }

        return hours;
    }

    get hasAuthorizedHours() {
        return this.authorizedHours && this.authorizedHours.length > 0;
    }

    get totalHours() {
        if (!this.mostRecentVisit) return 0;
        return (this.mostRecentVisit.mealPrepHours || 0) +
               (this.mostRecentVisit.ambulationHours || 0) +
               (this.mostRecentVisit.domesticServicesHours || 0);
    }

    handleCreateVisit() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Visit',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: `AccountId=${this.recordId}`
            }
        });
    }

    handleViewAllVisits() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                relationshipApiName: 'Visits',
                actionName: 'view'
            }
        });
    }

    navigateToVisit(event) {
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
}
