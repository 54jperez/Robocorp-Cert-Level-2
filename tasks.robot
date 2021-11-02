*** Settings ***
Documentation   Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium
Library           RPA.Excel.Files
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Tables
Library           RPA.FileSystem
Library           RPA.Dialogs
Library           RPA.RobotLogListener
Library           RPA.Robocorp.Vault
Library           Collections
Library           RPA.Archive


*** Keywords ***
Open the robot order website    
    ${secret}=    Get Secret    order_website
    Open Available Browser      ${secret}[website]


*** Keywords ***
GIVE UP ALL MY CONSTITUTIONAL RIGHTS FOR THE BENEFIT OF ROBOTSPAREBIN INDUSTRIES INC.
    Click Button    css:button.btn.btn-dark
    Wait Until Page Contains Element    id:preview

*** Keywords ***
Download The CSV File   
   Add heading    Send URL for CSV File
   Add text input    CSV_File_URL
   ...    label=Full URL
   ...    placeholder=Enter Full URL Here
   ...    rows=1
   ${result}=    Run dialog
   Download      ${result.CSV_File_URL}    overwrite=true
   ${Robot Orders}=    Read table from CSV  orders.csv
   #Download      https://robotsparebinindustries.com/orders.csv    overwrite=true
   [Return]    ${Robot Orders}


*** Keywords ***
Fill the form using the data from the CSV File
    ${Robot Orders}=    Read table from CSV  orders.csv    
    FOR  ${Robot Order}    IN    @{Robot Orders}
        Build And Order Your Robot      ${Robot Order}
        Preview Robot          
        Convert Receipt To PDF      ${Robot Order}
        Click Button    order-another
        GIVE UP ALL MY CONSTITUTIONAL RIGHTS FOR THE BENEFIT OF ROBOTSPAREBIN INDUSTRIES INC.
    END


*** Keywords ***
Build And Order Your Robot 
    [Arguments]  ${Robot Order}
    Select From List By Value    head     ${Robot Order}[Head]
    Click Element    id:id-body-${Robot Order}[Body]
    Input Text  xpath://*[starts-with(@id,"16")]  ${Robot Order}[Legs]
    Input Text  id:address  ${Robot Order}[Address]


*** Keywords ***
Preview Robot
    Click Button    preview
    Wait Until Page Contains Element  id:robot-preview-image
    Mute Run On Failure    Order Robot 
    Wait Until Keyword Succeeds    5x   5.5 sec    Order Robot

*** Keywords ***
Order Robot
    Click Button    order
    Wait Until Element Is Visible    id:receipt

*** Keywords ***
Convert Receipt To PDF
    [Arguments]  ${Robot Order}
    Wait Until Element Is Visible    robot-preview-image
    Wait Until Element Is Visible    id:receipt
    ${Receipt}=    Get Element Attribute    id:receipt    outerHTML
    Screenshot  robot-preview-image    ${CURDIR}${/}output${/}SalesReceipts${/}${Robot Order}[Order number]_sales_Order.jpeg
    Html To Pdf     ${Receipt}      ${CURDIR}${/}output${/}SalesReceipts${/}${Robot Order}[Order number]_sales_Order.pdf
    Add Watermark Image To PDF
    ...     image_path=${CURDIR}${/}output${/}SalesReceipts${/}${Robot Order}[Order number]_sales_Order.jpeg
    ...     source_path=${CURDIR}${/}output${/}SalesReceipts${/}${Robot Order}[Order number]_sales_Order.pdf
    ...     output_path=${CURDIR}${/}output${/}FinalReceipts.zip${/}${Robot Order}[Order number]_Final_receipt.pdf

*** Keywords ***
Create Zip Folder
    Archive Folder With Zip    ${CURDIR}${/}output${/}FinalReceipts.zip${/}    FinalReceipts.zip

*** Keywords ***
Close The Browser
    Close Browser

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
   Open the robot order website
   GIVE UP ALL MY CONSTITUTIONAL RIGHTS FOR THE BENEFIT OF ROBOTSPAREBIN INDUSTRIES INC.
   Download The CSV File
   Fill the form using the data from the CSV File
   Create Zip Folder
   [Teardown]    Close The Browser

