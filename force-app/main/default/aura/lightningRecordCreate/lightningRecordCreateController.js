({
    handleUploadFinished: function (cmp, event) {
        // Get the list of uploaded files
        //var uploadedFiles = event.getParam("files");
        alert("Files uploaded : ");
        
        
        // Get the file name
        //   uploadedFiles.forEach(file => console.log(file.name));
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        
        if (event.getSource().get("v.files").length > 0) {
            var filelist = event.getSource().get("v.files")[0] ;
            console.log('Filelist'+filelist);
            
            fileName = event.getSource().get("v.files")[0]['name'];
            alert("Files uploaded : "+fileName);
        }
        component.set("v.fileName", fileName);
         component.set("v.lstimg", filelist);
    },
    
    
    dosave: function(component, event , heloper){
        if (event.getSource().get("v.files").length > 0) {
            var fileInput = component.find("fileId").get("v.files");
            // get the first file using array index[0]  
            var file = fileInput;
            console.log('Filelist'+fileInput[0].image);
            alert("file uploaded ");
             component.set("v.lstimg", file);
        }
        else{
            alert ("please select file");
        }
    }
})