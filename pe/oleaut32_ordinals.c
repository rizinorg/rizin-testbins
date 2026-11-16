#include <windows.h>
#include <oleauto.h>
#include <stdio.h>

// Instructs Visual Studio to link the oleaut32.lib library.
// Alternatively, you can add it in Project Properties -> Linker -> Input.
#pragma comment(lib, "oleaut32.lib")

int main() {
    // 1. Creating a BSTR (Automation String)
    // SysAllocString is defined within oleaut32.dll.
    BSTR bstrHeader = SysAllocString(L"OLEAUT32 Analysis Test");

    if (bstrHeader == NULL) {
        printf("Memory allocation failed!\n");
        return 1;
    }

    // BSTRs are special structures that store length information at the start of the string.
    printf("BSTR Content: %S\n", bstrHeader);
    printf("BSTR Length: %u characters\n", SysStringLen(bstrHeader));

    // 2. Using the VARIANT Structure
    // VariantInit and VariantClear functions are located in oleaut32.dll.
    VARIANT vtContainer;
    VariantInit(&vtContainer);

    vtContainer.vt = VT_BSTR;
    vtContainer.bstrVal = SysAllocString(L"Embedded String");

    printf("BSTR inside Variant: %S\n", vtContainer.bstrVal);

    // 3. Cleanup Procedures
    // These calls are critical in OLE automation to prevent memory leaks.
    VariantClear(&vtContainer);
    SysFreeString(bstrHeader);

    printf("\nProcess completed successfully. Memory has been released.\n");

    return 0;
}