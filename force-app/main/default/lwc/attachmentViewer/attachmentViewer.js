import { LightningElement, api, wire } from 'lwc';
import getAllAttachments from '@salesforce/apex/AttachmentDropzoneController.getAllAttachments';


export default class AttachmentViewer extends LightningElement {

    @api recordId;

    records;
    width;
    height;

    // Retrieves all the active attributes
    @wire(getAllAttachments, {
        recordId: '$recordId',
    })
    attachments({ error, data }) {
        if (data) {
            this.records = JSON.parse(data);
            console.log(JSON.stringify(this.records));
        } else if (error) {
            console.log(error);
        }
    };

    _rendered = false;
    renderedCallback() {
        if(!this._rendered) {
            let container = this.template.querySelector('[data-id="content"]');
            if(container != null) {
                this.width = container.getBoundingClientRect().width;
                this.height = this.width*9/16;
                this._rendered = true;
            }
        }
    }
}