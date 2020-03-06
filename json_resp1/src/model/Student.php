<?php 

namespace Devscreencast\Models;

class Student
{
	public $name;
	public $course;
	public $level;
	public $def;
	public $collections = array(
	   'books' => ''
	  ,'music' => ''
	);
	
	public function __construct(
	   $name ,$course ,$level ,array $collections = []	 
	){
		$this->name         = $name;
		$this->course       = $course;
		$this->level		= $level;
		$this->def          = 102;
		$this->collections  = $collections;
		
        return array(
		 'name'         =>  $this->name        
		,'course'       =>  $this->course      
		,'level'        =>  $this->level
        ,'def'		    =>  $this->def
		,'collections'  =>  $this->collections 
		
		);
		
	}
	
	public function setName($name){
		$this->name = $name;		
	}
	
	
	
	
	
}




?>