SELECT * FROM students as S
inner join login as L on S.student_code = L.username
inner join student_details as SL on SL.student_code = S.student_code
inner join student_identification as SI on SI.student_code = S.student_code

where S.full_name = N'Lê Văn Quân'
