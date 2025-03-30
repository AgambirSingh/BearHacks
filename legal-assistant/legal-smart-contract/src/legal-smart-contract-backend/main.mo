import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Array "mo:base/Array";

actor LegalAssistant {

    // Defining the structure for a legal document
    public type Document = {
        name: Text;
        content: Text;
        timestamp: Int;  
        typeofDocument: Text;
        owner: Principal;
        version: Nat;   
        metadata: Text;
        status: Text;
    };

    // Store documents in a stable array
    stable var documents: [Document] = [];

    // Function to store a document
    public func storeDocument(
        name: Text, 
        content: Text, 
        docType: Text, 
        metadata: Text, 
        owner: Principal,
        status: Text
    ) : async Text {
        // Validate inputs
        if (Text.size(name) == 0 or Text.size(content) == 0) {
            return "Error: Document name or content cannot be empty.";
        };

        let timestamp = Time.now();
        let version : Nat = 1; // Initial version

        let newDocument : Document = {
            name = name;
            content = content;
            timestamp = timestamp;
            typeofDocument = docType;
            owner = owner;
            version = version;
            metadata = metadata;
            status = status;
        };

        // Store the document in the array
        documents := Array.append(documents, [newDocument]);
        
        return "Document stored successfully!";
    };

    // Add a dummy document when the contract is initialized
    public func initDummyDocument() : async Text {
        let dummyOwner = Principal.fromText("aaaaa-aa");
        return await storeDocument(
            "Dummy Contract",
            "This is a dummy document content.", 
            "Legal Agreement",
            "Dummy Metadata",
            dummyOwner,
            "Draft"
        );
    };

    public func getDocuments() : async [Document] {
        return documents;
    };

 public func updateDocument(name: Text, newContent: Text, newMetadata: Text) : async Text {
    documents := Array.map(documents, func(doc: Document) : Document {
      if (doc.name == name) {
        {
          name = doc.name;
          content = newContent;
          timestamp = Time.now();
          typeofDocument = doc.typeofDocument;
          owner = doc.owner;
          version = doc.version + 1;
          metadata = newMetadata;
          status = doc.status;
        }
      } else {
        doc
      }
    });
    "Document updated successfully"
  };

  public func deleteDocument(name: Text) : async Text {
    documents := Array.map(documents, func(doc: Document) : Document {
      if (doc.name == name) {
        {
          name = doc.name;
          content = "[DELETED]";
          timestamp = Time.now();
          typeofDocument = doc.typeofDocument;
          owner = doc.owner;
          version = doc.version;
          metadata = doc.metadata;
          status = "Deleted";
        }
      } else {
        doc
      }
    });
    "Document marked as deleted"
  };



    // Testing the getDocuments function
    public func testGetDocuments() : async [Document] {
        // First, initialize a dummy document
        ignore await initDummyDocument();
        
        // Then, retrieve the list of documents
        return documents;
    };
};


