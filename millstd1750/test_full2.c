typedef int Enumeration;
#define Ident_1 1
#define Ident_2 2
#define Ident_3 3

typedef int One_Thirty;
typedef int One_Fifty;
typedef char Capital_Letter;
typedef int Boolean;
typedef char Str_30[31];
typedef int Arr_1_Dim[50];

typedef struct record {
    struct record *Ptr_Comp;
    Enumeration Discr;
    Enumeration Enum_Comp;
    int Int_Comp;
    Str_30 Str_Comp;
} Rec_Type, *Rec_Pointer;

extern Rec_Pointer Ptr_Glob, Next_Ptr_Glob;
extern int Int_Glob;
extern Boolean Bool_Glob;
extern Capital_Letter Ch_1_Glob, Ch_2_Glob;
extern Arr_1_Dim Arr_1_Glob;

void Proc_1(Rec_Pointer Ptr_Val_Par);
void Proc_2(One_Fifty *Int_Par_Ref);
void Proc_3(Rec_Pointer *Ptr_Ref_Par);
Enumeration Func_1(Capital_Letter Ch_1_Par_Val, Capital_Letter Ch_2_Par_Val);
Boolean Func_2(Str_30 Str_1_Par_Ref, Str_30 Str_2_Par_Ref);

void increment(int *n) {
    (*n)++;
}

void Proc_1(Rec_Pointer Ptr_Val_Par) {
    Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;

    *Ptr_Val_Par->Ptr_Comp = *Ptr_Glob;
    Ptr_Val_Par->Int_Comp = 5;
    Next_Record->Int_Comp = Ptr_Val_Par->Int_Comp;
    Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
    Proc_3(&Next_Record->Ptr_Comp);

    if (Next_Record->Discr == Ident_1) {
        Next_Record->Int_Comp = 6;
        Proc_6(Ptr_Val_Par->Enum_Comp, &Next_Record->Enum_Comp);
        Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
        Proc_7(Next_Record->Int_Comp, 10, &Next_Record->Int_Comp);
    } else {
        *Ptr_Val_Par = *Ptr_Val_Par->Ptr_Comp;
    }
}

Enumeration Func_1(Capital_Letter Ch_1_Par_Val, Capital_Letter Ch_2_Par_Val) {
    Capital_Letter Ch_1_Loc = Ch_1_Par_Val;
    Capital_Letter Ch_2_Loc = Ch_1_Loc;

    if (Ch_2_Loc != Ch_2_Par_Val)
        return Ident_1;
    return Ident_2;
}

Boolean Func_2(Str_30 Str_1_Par_Ref, Str_30 Str_2_Par_Ref) {
    One_Thirty Int_Loc = 2;
    Capital_Letter Ch_Loc;

    while (Int_Loc <= 2) {
        if (Func_1(Str_1_Par_Ref[Int_Loc], Str_2_Par_Ref[Int_Loc + 1]) == Ident_1) {
            Ch_Loc = 'A';
            Int_Loc += 1;
        }
    }

    if (Ch_Loc >= 'W' && Ch_Loc < 'Z')
        Int_Loc = 7;
    if (Ch_Loc == 'X')
        return 1;
    return 0;
}

int main(int argc, char *argv[]) {
    int Int_1_Loc = 5;
    int Int_2_Loc = 5;
    int Int_3_Loc = 5;
    int Number_Of_Runs;

    Number_Of_Runs = (argc > 1) ? Int_1_Loc : 1;

    while (Number_Of_Runs--) {
        Proc_1(Ptr_Glob);
        Func_2(Arr_1_Glob, Arr_1_Glob);
        Int_2_Loc = Int_3_Loc;
        increment(&Int_2_Loc);
    }

    return 0;
}
