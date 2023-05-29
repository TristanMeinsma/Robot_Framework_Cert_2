*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the csv file
    ${csv_file}    Read csv file into Table
    Close the annoying modal
    Fill the form    ${csv_file}


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the csv file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=true

Read csv file into Table
    ${csv_file}    Read table from CSV    orders.csv    header=True
    RETURN    ${csv_file}

Close the annoying modal
    Wait And Click Button    css:.btn.btn-dark

Fill the form
    [Arguments]    ${csv_file}
    FOR    ${row}    IN    @{csv_file}
        Input One Order    ${row}
        ${pdf}    Store the receipt as a PDF file    ${row}
    END

Input One Order
    [Arguments]    ${row}
    Select From List By Index    head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    xpath=//input[@placeholder='Enter the part number for the legs']    ${row}[Legs]
    Input Text    address    ${row}[Address]
    Click Button    preview

    TRY
        Wait Until Keyword Succeeds    3x    1s    Click Button    order
    EXCEPT    AS    ${error}
        Log    ${error}
    END

Store the receipt as a PDF file
    [Arguments]    ${row}
    Wait Until Element Is Visible    receipt
    ${receipt}    Get Element Attribute    receipt    outerHTML

    # geen idee wtf hier fout gaat, iets met de location
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}${row}[Order number].pdf
    RETURN    ${receipt}
