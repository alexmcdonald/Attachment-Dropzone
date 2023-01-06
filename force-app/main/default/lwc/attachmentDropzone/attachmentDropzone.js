import { LightningElement, api } from 'lwc';
import saveAttachment from '@salesforce/apex/AttachmentDropzoneController.saveAttachment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';



export default class AttachmentDropzone extends LightningElement {

    //Inputs
    @api recordId;

    message = 'Drag-and-drop Content';

    onDragOver(event) {
        event.preventDefault();
    }

    onDrop(event) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        if (files.length>1) {
            return alert("You can only upload one content asset per record.");
        }

        let reader = new FileReader();
        reader.onloadend = function() {
            const dataURL = reader.result;
            //console.log(dataURL);
            this.upload(files[0], dataURL.match(/,(.*)$/)[1]);
        }.bind(this);
        reader.readAsDataURL(files[0]);
    }

    upload(file, base64Data) {

        console.log('Uploading');

        saveAttachment({
            parentId: this.recordId,
            fileName: file.name,
            base64Data: base64Data,
            contentType: file.type
        }).then((result) => {
            if(typeof result != "undefined") {
                this.message = "Attachment Uploaded";
                this.showToast();
                updateRecord({ fields: { Id: this.recordId } });
            }
        }).catch((error) => {
            console.log(JSON.stringify(error.message));
        })
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Attachment Saved!',
            message:
                'The attachment Id and link are in the content.',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }

}