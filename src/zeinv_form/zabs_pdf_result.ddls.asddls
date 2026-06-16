//@EndUserText.label: 'abstract entity for pdf download structure'
//define abstract entity ZABS_PDF_RESULT
//  with parameters parameter_name : parameter_type
//{
//    element_name : element_type;
//    
//}



@EndUserText.label: 'abstract entity for pdf download structure'
define abstract entity ZABS_PDF_RESULT
{
  filecontent : abap.rawstring;
  filename    : abap.string;
  mimetype    : abap.string;
}
