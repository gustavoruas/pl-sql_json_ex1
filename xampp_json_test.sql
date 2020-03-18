DECLARE
 l_req   utl_http.req;
 l_resp  utl_http.resp;
 l_value VARCHAR2(32000);
 g_status_code NUMBER;
 L_values_output VARCHAR2(3000);
 
 e_http_code EXCEPTION;
 
 l_http_det_exc BOOLEAN;
 
 --TBEX1_USER_JSON
 --TBEX1_COLLECTION_JSON
 TYPE t_rec_TBEX1_USER_JSON IS TABLE OF TBEX1_USER_JSON%ROWTYPE;
 TYPE t_rec_TBEX1_COLLECTION_JSON IS TABLE OF TBEX1_COLLECTION_JSON%ROWTYPE;
 
 --virtual tables
 l_tab_user_json           t_rec_TBEX1_USER_JSON;
 l_tab_collection_json     t_rec_TBEX1_COLLECTION_JSON;
 
 l_user_id NUMBER;
 
 -- {"status":"","student_data":[{"name":"Flash Gordon","course":"Class lesson","level":"12","collections":{"books":"IGET","music":"Book of gg"}},{"name":"Edu","course":"Geography","level":"300","collections":{"books":"IAs","music":"GET22"}},{"name":"Guanga","course":"Hist","level":"123","collections":{"books":"IAs","music":"GET22"}},{"name":"Troid","course":"Guist","level":"22","collections":{"books":"IAs","music":"GET22"}}]}
 --PLJSON_CODE.json 
 l_json json := json();
 
 l_json_values json := json();
 
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
    
        
    --Default print from JSON in DBMS_OUTPUT
    --l_json.print();
    
    --Gets the list element which is contained in []
    --l_json.path('student_data').print();
    
    --Creating json_list with [] element
    l_json_list := json_list(l_json.get('student_data'));
    
        
    --INITIALIZING type
    l_tab_user_json := t_rec_TBEX1_USER_JSON();
    l_tab_user_json.EXTEND(l_json_list.count());
    
    l_tab_collection_json := t_rec_TBEX1_COLLECTION_JSON();
    
    --Looping through elements
    FOR ind IN 1..l_json_list.count() LOOP
      
      --Iterate each element to see array
      IF l_json_list.get(ind).is_object() AND NOT(l_json_list.get(ind).IS_NULL)  THEN
        
        l_values_output := NULL;
      
        --l_json_list.get(ind).print();
        --Insert element into JSON object
        l_json_values := json(l_json_list.get(ind));   
        
        --Counts the amount of key pairs a json object has
        DBMS_OUTPUT.PUT_LINE('Json element keys:' || l_json_values.count());
        
        --Aquiring ID for parent line
        BEGIN        
          SELECT SEQ_TBEX1_USER_JSON.NEXTVAL INTO l_user_id FROM DUAL;        
        END;                              

        l_tab_user_json(ind).user_id             := l_user_id;
                
        --Iterate within each index and value of JSON object
        FOR ind1 IN 1..l_json_values.count() LOOP  
                
          IF  l_json_values.get(ind1).is_String THEN 
            L_values_output := L_values_output || l_json_values.get(ind1).get_string() || ' '  ;
          END IF;
          
          IF l_json_values.get(ind1).is_number THEN
            l_values_output := L_values_output || l_json_values.get(ind1).get_number() || ' '  ;
          END IF;
          
          --Populating type cols fro json object, matching per order element
          CASE ind1
            WHEN 1 THEN
              l_tab_user_json(ind).NAME           := l_json_values.get(ind1).get_string();
            WHEN 2 THEN
              l_tab_user_json(ind).COURSE         := l_json_values.get(ind1).get_string();
            WHEN 3 THEN                           
              l_tab_user_json(ind).LEVEL_DISC     := l_json_values.get(ind1).get_number();
            WHEN 4 THEN                           
              l_tab_user_json(ind).DEF            := l_json_values.get(ind1).get_number();
            ELSE
              NULL;              
          END CASE;
          
          DBMS_OUTPUT.PUT_LINE(' ELEMENT ' || ind1 || ' ' || l_json_values.get(ind1).get_type() );
         
          --Gets the Object type element (only 1 element)
          IF (l_json_values.get(ind1).IS_OBJECT)
            AND NOT(l_json_values.get(ind1).IS_NULL) 
          THEN
            
            DECLARE              
              l_col_json json := json();
            
              l_collection_id TBEX1_COLLECTION_JSON.COLLECTION_ID%TYPE;
              l_tb_size NUMBER;
              
            BEGIN
               
               l_col_json := json(l_json_values.get(ind1));
               
               --Aquiring current size of collection
               --IF l_tab_collection_json.count() = 0 THEN
               --  l_tb_size:= 1;
               --ELSE
               --  l_tb_size := l_tab_collection_json.count();
               --END IF;  
               l_tb_size := l_tab_collection_json.count() +1;
               
                  
               DBMS_OUTPUT.PUT_LINE(' **l_tb_size:' || l_tb_size || ' -l_tab_collection_json.count: ' ||l_tab_collection_json.count());
               
               --appending an element to the collection
               --l_tab_collection_json.EXTEND(1);
               l_tab_collection_json.EXTEND;
               
               DBMS_OUTPUT.PUT_LINE(' **l_tb_size:' || l_tb_size || ' - aftEXT l_tab_collection_json.count: ' ||l_tab_collection_json.count());
               
               BEGIN
                 SELECT SEQ_TBEX1_COLLECTION_JSON.NEXTVAL INTO l_collection_id FROM DUAL;
               END;
               --
               --populating collection
               l_tab_collection_json(l_tb_size).COLLECTION_ID    := l_collection_id;
               l_tab_collection_json(l_tb_size).USER_ID          := l_user_id;
               l_tab_collection_json(l_tb_size).BOOK             := l_col_json.get('books').get_String();  --getting by Key_pair name, when not ARRAY.
               l_tab_collection_json(l_tb_size).MUSIC            := l_col_json.get('music').get_String();
               l_tab_collection_json(l_tb_size).ID_LAST_UPDATED  := USER;
               l_tab_collection_json(l_tb_size).DTE_LAST_UPDATED := SYSDATE;
                           
            END;          
          
          --if looped element is an ARRAY ( When there is more than one object)
          ELSIF (l_json_values.get(ind1).IS_ARRAY)
            AND NOT(l_json_values.get(ind1).IS_NULL) 
          THEN
            DECLARE
              l_col_json json := json();
              l_col_list json_list;
              
              l_collection_id TBEX1_COLLECTION_JSON.COLLECTION_ID%TYPE;
              l_tb_size NUMBER := 0;
                            
            BEGIN
            
              l_col_list := json_list(l_json_values.get('collections'));
            
              --Aquiring current size of collection
              --IF l_tab_collection_json.count() = 0 THEN
              --  l_tb_size:= 1;
              --ELSE
              --  l_tb_size := l_tab_collection_json.count();
              --END IF; 
              
              -- Extending the collection size
              --l_tb_size := l_tb_size + l_col_list.count();
              l_tb_size := l_tab_collection_json.count() + l_col_list.count();
              l_tab_collection_json.EXTEND(l_col_list.count());
              
              DBMS_OUTPUT.PUT_LINE(' **l_col_listA:' || l_col_list.count() || ' - l_tb_size:' ||l_tb_size || ' -l_tab_collection_json.count: ' ||l_tab_collection_json.count());
  
              FOR col1 IN 1..l_col_list.count()
              LOOP
                --get each element of the array
                l_col_json := json(l_col_list.get(col1));
                
                --Fetch ID for child line
                BEGIN
                  SELECT SEQ_TBEX1_COLLECTION_JSON.NEXTVAL INTO l_collection_id FROM DUAL;
                END;
                
                 DBMS_OUTPUT.PUT_LINE(' **l_collection_id:' || l_collection_id); 
                
                -- l_tb_size-(col1-1) gets the last elements Extended in the collection
                l_tab_collection_json(l_tb_size-(col1-1)).COLLECTION_ID     := l_collection_id;
                l_tab_collection_json(l_tb_size-(col1-1)).USER_ID           := l_user_id;
                l_tab_collection_json(l_tb_size-(col1-1)).BOOK              := l_col_json.get('books').get_String();
                l_tab_collection_json(l_tb_size-(col1-1)).music             := l_col_json.get('music').get_String();
                l_tab_collection_json(l_tb_size-(col1-1)).ID_LAST_UPDATED   := USER;
                l_tab_collection_json(l_tb_size-(col1-1)).DTE_LAST_UPDATED  := SYSDATE;
              END LOOP;
              
            
            END;

          END IF;

        END LOOP; --END l_json_values l_tab_user_json
        
        
        --COntinuing last element population
        l_tab_user_json(ind).ID_LAST_UPDATED     := USER;
        l_tab_user_json(ind).DTE_LAST_UPDATED    := SYSDATE;
        
        
        DBMS_OUTPUT.PUT_LINE('Values of element(' ||ind||'): '||l_values_output
          || '  -  Obj type: ' || l_json_list.get(ind).get_type        
        );
               
        
      END IF;
     

    END LOOP; --END l_json_list (ind)
    
    --ISERTS INTO TABLE in father rows 
    IF l_tab_user_json.COUNT() > 0 OR l_tab_user_json IS NOT NULL THEN
      
      FORALL j IN l_tab_user_json.FIRST .. l_tab_user_json.LAST
        INSERT INTO TBEX1_USER_JSON VALUES l_tab_user_json(j);    
      
    END IF;
    
    --INSERTS INTO TABLE child rows
    IF l_tab_collection_json.COUNT() >0 OR l_tab_collection_json IS NOT NULL THEN
    
      FORALL j IN l_tab_collection_json.FIRST .. l_tab_collection_json.LAST
        INSERT INTO TBEX1_COLLECTION_JSON VALUES l_tab_collection_json(j);
    
      
      --Printing Type for viewing population
      --dbms_output.put_line('****Printing l_tab_collection_json:');
      --FOR j IN 1..l_tab_collection_json.COUNT() LOOP
      --  dbms_output.put_line( 'ROW' || j ||':' ||       
      --    l_tab_collection_json(j).COLLECTION_ID     ||' - '||
      --    l_tab_collection_json(j).USER_ID           ||' - '||
      --    l_tab_collection_json(j).BOOK              ||' - '||
      --    l_tab_collection_json(j).music             ||' - '||
      --    l_tab_collection_json(j).ID_LAST_UPDATED   ||' - '||
      --    l_tab_collection_json(j).DTE_LAST_UPDATED 
      --  );
      --  
      --END LOOP; 

    END IF;
    
    
    COMMIT;
    
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