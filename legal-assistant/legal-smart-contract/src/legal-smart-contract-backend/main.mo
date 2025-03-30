// import Time "mo:base/Time";
// import Principal "mo:base/Principal";
// import Text "mo:base/Text";
// import Array "mo:base/Array";
// import Result "mo:base/Result";
// import Int "mo:base/Int";

// actor LegalAssistant {

//     public type Metadata = {
//         creationDate: Int;
//         documentType: Text;
//         status: Text;
//         ownerID: Principal;
//     };

//     public type Document = {
//         id: Text;
//         name: Text;
//         metadata: Metadata;
//         content: Text;
//         version: Nat;
//     };

//     // Store documents in a stable array
//     stable var documents: [Document] = [];

//     // Function to store a document
//     public shared(msg) func storeDocument(
//         name: Text, 
//         content: Text, 
//         docType: Text
//     ) : async Text {
//         // Validate inputs
//         if (Text.size(name) == 0 or Text.size(content) == 0) {
//             return "Error: Document name or content cannot be empty.";
//         };

//         let timestamp = Time.now();
//         let id = Principal.toText(msg.caller) # "-" # Int.toText(timestamp);
        
//         let newDocument : Document = {
//             id = id;
//             name = name;
//             metadata = {
//                 creationDate = timestamp;
//                 documentType = docType;
//                 status = "Draft";
//                 ownerID = msg.caller;
//             };
//             content = content;
//             version = 1;
//         };

//         documents := Array.append(documents, [newDocument]);
        
//         return "Document stored successfully!";
//     };

//     // Function to get document metadata for all users
//     public query func getDocumentMetadata() : async [{id: Text; name: Text; metadata: Metadata}] {
//         Array.map(documents, func(doc: Document) : {id: Text; name: Text; metadata: Metadata} {
//             {
//                 id = doc.id;
//                 name = doc.name;
//                 metadata = doc.metadata;
//             }
//         })
//     };

//     // Function to get full document content, restricted to the owner
//     public shared(msg) func getFullDocument(id: Text) : async Result.Result<Document, Text> {
//         let document = Array.find(documents, func(doc: Document) : Bool { doc.id == id });
//         switch (document) {
//             case (null) { #err("Document not found") };
//             case (?doc) {
//                 if (doc.metadata.ownerID == msg.caller) {
//                     #ok(doc)
//                 } else {
//                     #err("Access denied")
//                 }
//             };
//         }
//     };

//     public shared(msg) func updateDocument(id: Text, newContent: Text, newStatus: Text) : async Result.Result<Text, Text> {
//         let documentIndex = Array.indexOf<Document>(
//             {
//                 id = id;
//                 name = "";
//                 metadata = { creationDate = 0; documentType = ""; status = ""; ownerID = msg.caller };
//                 content = "";
//                 version = 0;
//             },
//             documents,
//             func(a: Document, b: Document) : Bool { a.id == b.id }
//         );

//         switch (documentIndex) {
//             case (null) { #err("Document not found") };
//             case (?index) {
//                 if (documents[index].metadata.ownerID != msg.caller) {
//                     return #err("Access denied");
//                 };

//                 let updatedDoc : Document = {
//                     id = documents[index].id;
//                     name = documents[index].name;
//                     metadata = {
//                         creationDate = documents[index].metadata.creationDate;
//                         documentType = documents[index].metadata.documentType;
//                         status = newStatus;
//                         ownerID = documents[index].metadata.ownerID;
//                     };
//                     content = newContent;
//                     version = documents[index].version + 1;
//                 };

//                 // documents[index] := updatedDoc;
//                 // var mutableDocuments = Array.thaw(documents);
//                 var mutableDocuments = Array.thaw<Document>(documents);
//                 mutableDocuments[index] := updatedDoc;

//                 documents := Array.freeze(mutableDocuments);
//                 #ok("Document updated successfully")
//             };
//         }
//     };

//     public shared(msg) func deleteDocument(id: Text) : async Result.Result<Text, Text> {
//         let documentIndex = Array.indexOf<Document>(
//             {
//                 id = id;
//                 name = "";
//                 metadata = { creationDate = 0; documentType = ""; status = ""; ownerID = msg.caller };
//                 content = "";
//                 version = 0;
//             },
//             documents,
//             func(a: Document, b: Document) : Bool { a.id == b.id }
//         );

//         switch (documentIndex) {
//             case (null) { #err("Document not found") };
//             case (?index) {
//                 if (documents[index].metadata.ownerID != msg.caller) {
//                     return #err("Access denied");
//                 };

//                 let deletedDoc : Document = {
//                     id = documents[index].id;
//                     name = documents[index].name;
//                     metadata = {
//                         creationDate = documents[index].metadata.creationDate;
//                         documentType = documents[index].metadata.documentType;
//                         status = "Deleted";
//                         ownerID = documents[index].metadata.ownerID;
//                     };
//                     content = "[DELETED]";
//                     version = documents[index].version;
//                 };

//                 // documents[index] := deletedDoc;
//         var mutableDocuments = Array.thaw<Document>(documents);
//         mutableDocuments[index] := deletedDoc;
//         documents := Array.freeze(mutableDocuments);
//                 #ok("Document marked as deleted")
//             };
//         }
//     };

//     // Add a dummy document when the contract is initialized
//     public func initDummyDocument() : async Text {
//         let dummyOwner = Principal.fromText("aaaaa-aa");
//         return await storeDocument(
//             "Dummy Contract",
//             "This is a dummy document content.", 
//             "Legal Agreement"
//         );
//     };

//     // Testing the getDocumentMetadata function
//     public func testGetDocumentMetadata() : async [{id: Text; name: Text; metadata: Metadata}] {
//         // First, initialize a dummy document
//         ignore await initDummyDocument();
        
//         // Then, retrieve the list of document metadata
//         return await getDocumentMetadata();
//     };
// }

import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Int "mo:base/Int";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Buffer "mo:base/Buffer";

actor LegalAssistant {

    public type Metadata = {
        creationDate: Int;
        documentType: Text;
        status: Text;
        ownerID: Principal;
        fileSize: Nat;
        mimeType: Text;
    };

    public type Document = {
        id: Text;
        name: Text;
        metadata: Metadata;
        content: [Blob];
        version: Nat;
    };

    // Store documents in a stable array
    stable var documents: [Document] = [];

    // Maximum chunk size (1MB)
    let MAX_CHUNK_SIZE : Nat = 1024 * 1024;

    // Function to store a document
    public shared(msg) func storeDocument(
        name: Text, 
        content: [Blob], 
        docType: Text,
        mimeType: Text
    ) : async Result.Result<Text, Text> {
        // Validate inputs
        if (Text.size(name) == 0 or content.size() == 0) {
            return #err("Error: Document name or content cannot be empty.");
        };

        let totalSize = Array.foldLeft<Blob, Nat>(content, 0, func (acc, chunk) { acc + chunk.size() });
        if (totalSize > 3 * 1024 * 1024) {
            return #err("Error: File size exceeds 3MB limit.");
        };

        let timestamp = Time.now();
        let id = Principal.toText(msg.caller) # "-" # Int.toText(timestamp);
        
        let newDocument : Document = {
            id = id;
            name = name;
            metadata = {
                creationDate = timestamp;
                documentType = docType;
                status = "Draft";
                ownerID = msg.caller;
                fileSize = totalSize;
                mimeType = mimeType;
            };
            content = content;
            version = 1;
        };

        documents := Array.append(documents, [newDocument]);
        
        #ok("Document stored successfully!")
    };

    // Function to get document metadata for all users
    public query func getDocumentMetadata() : async [{id: Text; name: Text; metadata: Metadata}] {
        Array.map(documents, func(doc: Document) : {id: Text; name: Text; metadata: Metadata} {
            {
                id = doc.id;
                name = doc.name;
                metadata = doc.metadata;
            }
        })
    };

    // Function to get full document content, restricted to the owner
    public shared(msg) func getFullDocument(id: Text) : async Result.Result<Document, Text> {
        let document = Array.find(documents, func(doc: Document) : Bool { doc.id == id });
        switch (document) {
            case (null) { #err("Document not found") };
            case (?doc) {
                if (doc.metadata.ownerID == msg.caller) {
                    #ok(doc)
                } else {
                    #err("Access denied")
                }
            };
        }
    };

    // Function to update a document
    public shared(msg) func updateDocument(id: Text, newContent: [Blob], newStatus: Text) : async Result.Result<Text, Text> {
        let documentIndex = Array.indexOf<Document>(
            {
                id = id;
                name = "";
                metadata = { creationDate = 0; documentType = ""; status = ""; ownerID = msg.caller; fileSize = 0; mimeType = "" };
                content = [];
                version = 0;
            },
            documents,
            func(a: Document, b: Document) : Bool { a.id == b.id }
        );

        switch (documentIndex) {
            case (null) { #err("Document not found") };
            case (?index) {
                if (documents[index].metadata.ownerID != msg.caller) {
                    return #err("Access denied");
                };

                let totalSize = Array.foldLeft<Blob, Nat>(newContent, 0, func (acc, chunk) { acc + chunk.size() });
                if (totalSize > 3 * 1024 * 1024) {
                    return #err("Error: File size exceeds 3MB limit.");
                };

                let updatedDoc : Document = {
                    id = documents[index].id;
                    name = documents[index].name;
                    metadata = {
                        creationDate = documents[index].metadata.creationDate;
                        documentType = documents[index].metadata.documentType;
                        status = newStatus;
                        ownerID = documents[index].metadata.ownerID;
                        fileSize = totalSize;
                        mimeType = documents[index].metadata.mimeType;
                    };
                    content = newContent;
                    version = documents[index].version + 1;
                };

                var mutableDocuments = Array.thaw<Document>(documents);
                mutableDocuments[index] := updatedDoc;
                documents := Array.freeze(mutableDocuments);
                #ok("Document updated successfully")
            };
        }
    };

    // Function to delete a document (soft delete)
    public shared(msg) func deleteDocument(id: Text) : async Result.Result<Text, Text> {
        let documentIndex = Array.indexOf<Document>(
            {
                id = id;
                name = "";
                metadata = { creationDate = 0; documentType = ""; status = ""; ownerID = msg.caller; fileSize = 0; mimeType = "" };
                content = [];
                version = 0;
            },
            documents,
            func(a: Document, b: Document) : Bool { a.id == b.id }
        );

        switch (documentIndex) {
            case (null) { #err("Document not found") };
            case (?index) {
                if (documents[index].metadata.ownerID != msg.caller) {
                    return #err("Access denied");
                };

                let deletedDoc : Document = {
                    id = documents[index].id;
                    name = documents[index].name;
                    metadata = {
                        creationDate = documents[index].metadata.creationDate;
                        documentType = documents[index].metadata.documentType;
                        status = "Deleted";
                        ownerID = documents[index].metadata.ownerID;
                        fileSize = documents[index].metadata.fileSize;
                        mimeType = documents[index].metadata.mimeType;
                    };
                    content = [];
                    version = documents[index].version;
                };

                var mutableDocuments = Array.thaw<Document>(documents);
                mutableDocuments[index] := deletedDoc;
                documents := Array.freeze(mutableDocuments);
                #ok("Document marked as deleted")
            };
        }
    };

    // Add a dummy document when the contract is initialized
    public func initDummyDocument() : async Text {
        let dummyContent = Blob.fromArray([10, 20, 30, 40, 50] : [Nat8]);
        let result = await storeDocument(
            "Dummy Contract",
            [dummyContent], 
            "Legal Agreement",
            "text/plain"
        );
        switch (result) {
            case (#ok(message)) { message };
            case (#err(error)) { error };
        }
    };

    // Testing the getDocumentMetadata function
    public func testGetDocumentMetadata() : async [{id: Text; name: Text; metadata: Metadata}] {
        // First, initialize a dummy document
        ignore await initDummyDocument();
        
        // Then, retrieve the list of document metadata
        return await getDocumentMetadata();
    };
}

