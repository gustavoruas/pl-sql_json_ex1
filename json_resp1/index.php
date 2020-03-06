<?php
//require_once __DIR__ ."/vendor/autoload.php";
require_once __DIR__ ."/src/JsonResponse.php";
require_once __DIR__ ."/src/Model/Student.php";

//use Devscreencast\ResponseClass\JsonResponse;
use Devscreencast\ResponseClass\JsonResponse AS JsonResponse;
use Devscreencast\Models\Student;

$student_list = array();

$student = array(
    'name' => 'John Doe',
    'course' => 'Software Engineering',
    'level' => '200',
    'collections' => ['books' => 'Intro to UML', 'music' => 'rap']
);

//Single object definition
$student_class = array (
  new Student(
    'Student Class'
    ,'Class lesson'
    ,'300'
    ,['books' => 'Intro to UML', 'music' => 'rap']
  )
);

//calling class Method
//$student_class->setName('Eduarda');

array_push($student,$student_class);
//

array_push($student_list,
  new Student(
    'Flash Gordon'
    ,'Class lesson'
    ,'12'
    ,['books' => 'IGET', 'music' => 'Book of gg']
  )
);

array_push($student_list,
  new Student(
    'Edu'
    ,'Geography'
    ,'300'
    ,['books' => 'IAs', 'music' => 'GET22']
  )
);

array_push($student_list,
  new Student(
    'Guanga'
    ,'Hist'
    ,'123'
    ,['books' => 'IAs', 'music' => 'GET22']
  )
);

array_push($student_list,
  new Student(
    'Troid'
    ,'Guist'
    ,'22'
    ,['books' => 'IAs', 'music' => 'GET22']
  )
);


//new Devscreencast\ResponseClass\JsonResponse('unauthorized', '', $student);
new JsonResponse('', '', $student_list);


