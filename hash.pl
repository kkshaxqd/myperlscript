%fruit=("apples"=>"17","bananas"=>"9","oranges"=>"none");#生成一个哈希
print $fruit{"bananas"},"\n\n";
$fruit{"watermelon"}="15";#给关联数组添加新的元素
foreach $price (keys(%fruit)){ 
       $record = $fruit{$price};
	   print $record,"\n";
} 


