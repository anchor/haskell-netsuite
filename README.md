Netsuite Connector for Haskell
==============================

Background
----------

Helps Haskell applications communicate with Netsuite's SuiteScript API.

The Netsuite Connector for Haskell uses restlet code developed as part of Ruby's ns_connector gem. See [the original ns_connector repository](https://github.com/christian-marie/ns_connector) for more information.

Exposed Restlet Actions
-----------------------

* retrieveNS
* fetchSublistNS
* rawSearchNS
* searchNS
* createNS
* attachNS
* detachNS
* updateNS
* updateSublistNS
* deleteNS
* invoicePdfNS
* transformNS

Usage
-----

To get started with these examples, open up GHCI and run something like the following, customising NsRestletConfig where appropriate, to get your environment ready.

All the functions below will return Value objects as defined by Data.Aeson.

```
import Data.Aeson
import Data.HashMap
import Data.Maybe
import Network.URI
import Netsuite.Connect
import Netsuite.Restlet.Configuration
import Netsuite.Types.Data

let testRestletConfig = NsRestletConfig
                        (fromJust $ parseURI "https://rest.netsuite.com/app/site/hosting/restlet.nl?script=123&deploy=1") -- URL for your script endpoint
                        123456 -- NetSuite customer ID
                        1000 -- NetSuite role ID
                        "netsuite-user@yourcompany.example.com" -- identifier
                        "mypassword" -- password
                        Nothing -- custom user agent
                        Nothing -- represents custom fields for each entity type
```

Note that we've added a couple of Aeson-manipulating functions to help you create your data.  
For example, `newNsData` is equivalent to `NsData . object`.

Here's a rough example of fetching a customer info. Run this in ghci:

```
retrieveNS testRestletConfig "customer" 12345
```

You should get back an object containing all the fields for that customer.

A similar action is used for fetching credit cards, address books and so on:

```
fetchSublistNS testRestletConfig ("customer","creditcards") 12345
```

A raw search:

```
rawSearchNS testRestletConfig "customer" [(NsFilter "lastmodifieddate" Nothing OnOrAfter (Just "daysAgo1") Nothing)] (toSearchCols [["externalid"], ["entityid"]])
```

And a simple search:

```
searchNS testRestletConfig "customer" [(NsFilter "lastmodifieddate" Nothing OnOrAfter (Just "daysAgo1") Nothing)]
```

Creating a new contact:

```
let d = newNsData ["firstname" .= "Jane", "lastname" .= "Doe", "email" .= "jane.doe@example.com"]
let subd = NsSublistData [("addressbook", [newNsData ["addr1" .= "Unit 1", "addr2" .= "123 Sesame Street", "city" .= "Sydney", "state" .= "NSW", "zip" .= "2000", "country" .= "AU"]])]
createNS testRestletConfig "contact" d subd
```

Updating an existing contact (123456):

```
updateNS testRestletConfig "contact" (newNsData ["id" .= "123456", "firstname" .= "Wendy", "lastname" .= "Darling"])
```

Updating an existing contact's address book sublist:

```
updateSublistNS testRestletConfig ("contact","addressbook") 123456 [newNsData ["addr1" .= "Second Star to the Left", "addr2", "Straight on 'til Morning", "city" .= "Lost Boys' Hideout", "state" .= "Neverland", "zip" .= "12345", "country" .= "GB"]]
```

Attaching a contact (123456) to a customer (12345), with a default role:

```
attachNS testRestletConfig "customer" [12345] "contact" 123456 (newNsData [])
```

Detaching a contact (123456) from a customer (12345):

```
detachNS testRestletConfig "customer" [12345] "contact" 123456
```

Deleting a contact record:

```
deleteNS testRestletConfig "contact" 123456
```

Downloading an invoice PDF:

```
invoicePdfNS testRestletConfig 123456
```

Transforming a customer to a sales order:

```
transformNS testRestletConfig "customer" "salesorder" 12345 (newNsData [])
```

Netsuite Types
--------------

* Customer
  * Address Book
  * Contact Roles
  * Credit Cards
  * Currency
  * Download
  * Group Pricing
  * Item Pricing
  * Partners
  * Sales Team
* Contact
  * Address Book
* Credit Memo
  * Invoices Applied To
  * Line Item
  * Partners
  * Sales Team
* Customer Deposit
* Customer Payment
  * Invoices Applied To
  * Credit
  * Deposit
* Discount Item
* Invoice
  * Expenses Cost
  * Line Item
  * Line Item Cost
  * Partners
  * Sales Team
  * Shipping Group
  * Time
* Non-Inventory Item
  * Price 1
  * Price 2
  * Price 3
  * Price 4
  * Price 5
  * Site Category
* Sales Order
  * Partners
  * Sales Team
  * Shipping Group
