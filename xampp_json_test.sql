DECLARE
 l_req   utl_http.req;
 l_resp  utl_http.resp;
 l_value VARCHAR2(32000);
 g_status_code NUMBER;
 L_values_output VARCHAR2(3000);
 
 e_http_code EXCEPTION;
 
 l_http_det_exc BOOLEAN;
 
 
 -- {"status":"","student_data":[{"name":"Flash Gordon","course":"Class lesson","level":"12","collections":{"books":"IGET","music":"Book of gg"}},{"name":"Edu","course":"Geography","level":"300","collections":{"books":"IAs","music":"GET22"}},{"name":"Guanga","course":"Hist","level":"123","collections":{"books":"IAs","music":"GET22"}},{"name":"Troid","course":"Guist","level":"22","collections":{"books":"IAs","music":"GET22"}}]}
 --PLJSON_CODE.json 
 l_json json := json();
 
 l_sub_json json := json();
 
 --Fetches element with []
 l_json_list json_list;

 
BEGIN
  --utl_http.get_response_error_check;
  utl_http.get_detailed_excp_support(l_http_det_exc);

  BEGIN
    --XAMPP enabled.
    l_req := utl_http.begin_request('http://192.168.208.99/json_resp1/');
        
    utl_http.set_header(l_req, 'Content-Type', 'application/json');
     
    l_resp := utl_http.get_response(l_req);
    
    
    IF (l_resp.status_code = utl_http.HTTP_OK ) THEN    --STATUS code 200 
    
      utl_http.read_text(l_resp, l_value);    
      
      --return status of request
      dbms_output.put_line('Status:' || l_resp.status_code || ' HTTP: ' ||l_resp.http_version);
      
      dbms_output.put_line('full JSON: ' ||l_value || CHR(10));  
    
    ELSE
      
      g_status_code := l_resp.status_code;
      utl_http.end_response(l_resp);
      
      RAISE e_http_code;

    END IF;
    
    utl_http.end_response(l_resp);
    
    --utl_http.end_request(l_req);

  EXCEPTION
    WHEN utl_http.end_of_body THEN
      dbms_output.put_line('  **exception end_of_body');
      utl_http.end_response(l_resp);
      
    WHEN utl_http.too_many_requests  THEN
      utl_http.end_request(l_req);
      
    --WHEN utl_http.bad_argument THEN
  
  END;

  IF l_value IS NOT NULL THEN
    l_json := PLJSON_CODE.json(l_value);  
    
    --return amount of JSON elements
    dbms_output.put_line('Count Elements: ' || l_json.count());    

    dbms_output.put_line('Element: ' || l_json.get('student_data').get_string());
    
    --Default print from JSON in DBMS_OUTPUT
    --l_json.print();
    
    --Gets the list element which is contained in []
    --l_json.path('student_data').print();
    
    --Creating json_list with [] element
    l_json_list := json_list(l_json.get('student_data'));
    
    dbms_output.put_line('  **ELement in [ ]: ' || l_json_list.count());
    
    --Looping through elements
    FOR ind IN 1..l_json_list.count() LOOP
      
      --verify if element is array []
      IF l_json_list.get(2).is_array() THEN
        
        --gets element position
        l_json_list.get(ind).print();
      END IF;   
      
      --Iterate each element to see array
      IF l_json_list.get(ind).is_object() AND NOT(l_json_list.get(ind).IS_NULL)  THEN
        
        l_values_output := NULL;
      
        --l_json_list.get(ind).print();
        --Insert element into JSON object
        l_sub_json := json(l_json_list.get(ind));   
        
        --Counts the amount of key pairs a json object has
        DBMS_OUTPUT.PUT_LINE('Json element keys:' || l_sub_json.count());
        
        --Iterate within each index and value of JSON object
        FOR ind1 IN 1..l_sub_json.count() LOOP  
                
          IF  l_sub_json.get(ind1).is_String THEN 
            L_values_output := L_values_output || l_sub_json.get(ind1).get_string() || ' '  ;
          END IF;
          
          IF l_sub_json.get(ind1).is_number THEN
            l_values_output := L_values_output || l_sub_json.get(ind1).get_number() || ' '  ;
          END IF;

        END LOOP; --END l_sub_json
                
        DBMS_OUTPUT.PUT_LINE('Values of element(' ||ind||'): '||l_values_output);
      
      END IF;
     

    END LOOP; --END l_json_list
    
    
  END IF;  
  
  
EXCEPTION
  WHEN utl_http.end_of_body THEN
    dbms_output.put_line('  **exception end_of_body');
    utl_http.end_response(l_resp);
  
  WHEN e_http_code THEN
    dbms_output.put_line('HTTP code exception: ' || g_status_code);

  WHEN OTHERS THEN
    --utl_http.end_response(l_resp);
    RAISE_APPLICATION_ERROR(-20012,'error - ' || SQLERRM ||' - '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()); 
     

END;