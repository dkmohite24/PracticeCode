import { LightningElement, api } from 'lwc';

export default class FaqPagination extends LightningElement {
    @api totalPages;
    @api currentPage;
    clickedPage;

    get pages() {
        return Array.from({ length: this.totalPages }, (_, i) => i + 1);
    }

    handlePageClick(event) {
        const selectedPage = parseInt(event.target.label, 10);
        const pageChangeEvent = new CustomEvent('pagechange', {
            detail: { selectedPage }
        });
        this.dispatchEvent(pageChangeEvent);
        this.clickedPage = selectedPage;
        this.changeColorOnClick();
    }

    renderedCallback() {
        this.clickedPage;
        this.changeColorOnClick();
    }

     changeColorOnClick() {
        this.template.querySelectorAll('lightning-button').forEach(e => {
            const page = parseInt(e.label, 10);
            e.classList.toggle('currentPage', page === this.clickedPage);
            e.blur();
        });
    }
}