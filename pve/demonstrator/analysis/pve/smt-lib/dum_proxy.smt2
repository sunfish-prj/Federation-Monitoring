;#######################
;RECORD DATATYPE with BOTTOM and ERROR
;#######################
(declare-datatypes (U) ((TValue (mk-val (val U)(miss Bool)(err Bool)))))

;#######################
;Set of elements of type T with attached an integer index
;#######################
(define-sort Set (T) (Array Int T)) 
;################### STRING DECLARATIONs #######################
 (declare-datatypes () ((String s_129.27.142.49 s_POST s__dem_app_dem_ s__dem_app_dem
 			  s_AdditionalStringValue )))
;################### FACPL FUNCTION DECLARATIONs #######################
(define-fun isFalse ((x (TValue Bool))) Bool
	(ite (= x (mk-val false false false)) true false)
)

(define-fun isTrue ((x (TValue Bool))) Bool
	(ite (= x (mk-val true false false)) true false)
)

(define-fun isBool ((x (TValue Bool))) Bool
		(ite (or (isFalse x) (isTrue x))
			true
			false
		)
)

(define-fun isNotBoolValue ((x (TValue Bool))) Bool
		(ite (or (isFalse x) (isTrue x)) 
			false
			(ite (and (not (miss x)) (not (err x)))
				true
				false
			)
		)
)

(define-fun FAnd ((x (TValue Bool)) (y (TValue Bool))) (TValue Bool)
	(ite (and (isTrue x) (isTrue y))
		(mk-val true false false)
		(ite (or (isFalse x) (isFalse y))
			(mk-val false false false)
			(ite (or (err x) (err y))
				(mk-val false false true)
				(mk-val false true false)
			)
		)
	)
)

(define-fun FOr ((x (TValue Bool)) (y (TValue Bool))) (TValue Bool)
	(ite (or (isTrue x) (isTrue y))
		(mk-val true false false)
		(ite (or (err x) (err y))
			(mk-val false false true)
			(ite (or (miss x) (miss y))
				(mk-val false true true)
				(mk-val false false false)
			)
		)
	)
)

(define-fun FNot ((x (TValue Bool))) (TValue Bool)
	(ite (isTrue x)
		(mk-val false false false)
		(ite (isFalse x)
			(mk-val true false false)
			(ite (miss x)
				(mk-val false true false)
				(mk-val false false true)
			)
		)
	)
)
(define-fun equalBool ((x (TValue Bool)) (y (TValue Bool))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (= (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun equalInt ((x (TValue Int)) (y (TValue Int))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (= (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun equalReal ((x (TValue Real)) (y (TValue Real))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (= (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun notequalBool ((x (TValue Bool)) (y (TValue Bool))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (= (val x) (val y))
				(mk-val false false false)
				(mk-val true false false)
			)
		)
	)
)

(define-fun notequalInt ((x (TValue Int)) (y (TValue Int))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (= (val x) (val y))
				(mk-val false false false)
				(mk-val true false false)
			)
		)
	)
)

(define-fun notequalReal ((x (TValue Real)) (y (TValue Real))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (= (val x) (val y))
				(mk-val false false false)
				(mk-val true false false)
			)
		)
	)
)

(define-fun isValString ((x (TValue String))) Bool
	(ite (and (not (miss x)) (not (err x))) true false)
)

(define-fun equalString ((x (TValue String)) (y (TValue String))) (TValue Bool)
	(ite (and (isValString x) (isValString y))
		(ite (= (val x) (val y))
			(mk-val true false false)
			(mk-val false false false)
		)
		(ite (or (err x) (err y))
			(mk-val false false true)
			(mk-val false true false)
		)
	)
)

(define-fun notequalString ((x (TValue String)) (y (TValue String))) (TValue Bool)
		(ite (and (isValString x) (isValString y))
			(ite (= (val x) (val y))
				(mk-val false false false)
				(mk-val true false false)
			)
			(ite (or (err x) (err y))
				(mk-val false false true)
				(mk-val false true false)
			)
		)
)

(define-fun isValSetString ((x (TValue (Set String)))) Bool
	(ite (and (not (miss x)) (not (err x))) true false)
)

(define-fun inString ((x (TValue String)) (y (TValue (Set String)))) (TValue Bool)
	(ite (or (err x)(err y)) 
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (exists ((i Int))
						(= (val x) (select (val y) i))
				  )
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun isValInt ((x (TValue Int))) Bool
	(ite (and (not (miss x)) (not (err x))) true false)
)

(define-fun lessthanInt ((x (TValue Int)) (y (TValue Int))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (< (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun lessthanorequalInt ((x (TValue Int)) (y (TValue Int))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (<= (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun greaterthanInt ((x (TValue Int)) (y (TValue Int))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (> (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun greaterthanorequalInt ((x (TValue Int)) (y (TValue Int))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (>= (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun additionInt ((x (TValue Int)) (y (TValue Int))) (TValue Int)
	(ite (and (isValInt x) (isValInt y))
		(mk-val (+ (val x) (val y)) false false)
		(ite (or (err x) (err y))
			(mk-val 0 false true)
			(mk-val 0 true false)
		)
	)
)

(define-fun subtractInt ((x (TValue Int)) (y (TValue Int))) (TValue Int)
	(ite (and (isValInt x) (isValInt y))
		(mk-val (- (val x) (val y)) false false)
		(ite (or (err x) (err y))
			(mk-val 0 false true)
			(mk-val 0 true false)
		)
	)
)


(define-fun multiplyInt ((x (TValue Int)) (y (TValue Int))) (TValue Int)
	(ite (and (isValInt x) (isValInt y))
		(mk-val (* (val x) (val y)) false false)
		(ite (or (err x) (err y))
			(mk-val 0 false true)
			(mk-val 0 true false)
		)
	)
)


(define-fun divideInt ((x (TValue Int)) (y (TValue Int))) (TValue Int)
	(ite (and (isValInt x) (isValInt y))
		(mk-val (div (val x) (val y)) false false)
		(ite (or (err x) (err y))
			(mk-val 0 false true)
			(mk-val 0 true false)
		)
	)
)

(define-fun isValReal ((x (TValue Real))) Bool
	(ite (and (not (miss x)) (not (err x))) true false)
)

(define-fun lessthanReal ((x (TValue Real)) (y (TValue Real))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (< (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun lessthanorequalReal ((x (TValue Real)) (y (TValue Real))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (<= (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun greaterthanReal ((x (TValue Real)) (y (TValue Real))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (> (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun greaterthanorequalReal ((x (TValue Real)) (y (TValue Real))) (TValue Bool)
	(ite (or (err x) (err y))
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (>= (val x) (val y))
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun additionReal ((x (TValue Real)) (y (TValue Real))) (TValue Real)
	(ite (and (isValReal x) (isValReal y))
		(mk-val (+ (val x) (val y)) false false)
		(ite (or (err x) (err y))
			(mk-val 0.0 false true)
			(mk-val 0.0 true false)
		)
	)
)

(define-fun subtractReal ((x (TValue Real)) (y (TValue Real))) (TValue Real)
	(ite (and (isValReal x) (isValReal y))
		(mk-val (- (val x) (val y)) false false)
		(ite (or (err x) (err y))
			(mk-val 0.0 false true)
			(mk-val 0.0 true false)
		)
	)
)


(define-fun multiplyReal ((x (TValue Real)) (y (TValue Real))) (TValue Real)
	(ite (and (isValReal x) (isValReal y))
		(mk-val (* (val x) (val y)) false false)
		(ite (or (err x) (err y))
			(mk-val 0.0 false true)
			(mk-val 0.0 true false)
		)
	)
)


(define-fun divideReal ((x (TValue Real)) (y (TValue Real))) (TValue Real)
	(ite (and (isValReal x) (isValReal y))
		(mk-val (/ (val x) (val y)) false false)
		(ite (or (err x) (err y))
			(mk-val 0.0 false true)
			(mk-val 0.0 true false)
		)
	)
)
(define-fun isValSetInt ((x (TValue (Set Int)))) Bool
	(ite (and (not (miss x)) (not (err x))) true false)
)

(define-fun isValSetReal ((x (TValue (Set Real)))) Bool
	(ite (and (not (miss x)) (not (err x))) true false)
)

(define-fun isValSetBool ((x (TValue (Set Bool)))) Bool
	(ite (and (not (miss x)) (not (err x))) true false)
)

(define-fun inBool ((x (TValue Bool)) (y (TValue (Set Bool)))) (TValue Bool)
	(ite (or (err x)(err y)) 
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (exists ((i Int))
						(= (val x) (select (val y) i))
				  )
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun inReal ((x (TValue Real)) (y (TValue (Set Real)))) (TValue Bool)
	(ite (or (err x)(err y)) 
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (exists ((i Int))
						(= (val x) (select (val y) i))
				  )
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)

(define-fun inInt ((x (TValue Int)) (y (TValue (Set Int)))) (TValue Bool)
	(ite (or (err x)(err y)) 
		(mk-val false false true)
		(ite (or (miss x) (miss y))
			(mk-val false true false)
			(ite (exists ((i Int))
						(= (val x) (select (val y) i))
				  )
				(mk-val true false false)
				(mk-val false false false)
			)
		)
	)
)
;################################ END DATATYPEs AND FUNCTIONs DECLARATION #############################

;################### ATTRIBUTE DECLARATIONs #######################
(declare-const n_response/response - code (TValue Int))
(assert (not (and (miss n_response/response - code) (err n_response/response - code))))
 
(declare-const n_service/id (TValue String))
(assert (not (and (miss n_service/id) (err n_service/id))))
 
(declare-const n_response/path (TValue String))
(assert (not (and (miss n_response/path) (err n_response/path))))
 
(declare-const n_request/path (TValue String))
(assert (not (and (miss n_request/path) (err n_request/path))))
 
(declare-const n_request/method (TValue String))
(assert (not (and (miss n_request/method) (err n_request/method))))
 
(declare-const n_response/method (TValue String))
(assert (not (and (miss n_response/method) (err n_response/method))))
 
;################### CONSTANTs DECLARATIONs #######################
 
(declare-const const_200 (TValue Int))
(assert (= (val const_200) 200))
(assert (not (miss const_200))) 
(assert (not (err const_200)))
 
(declare-const const_129.27.142.49 (TValue String))
(assert (= (val const_129.27.142.49) s_129.27.142.49))
(assert (not (miss const_129.27.142.49))) 
(assert (not (err const_129.27.142.49)))
 
(declare-const const_POST (TValue String))
(assert (= (val const_POST) s_POST))
(assert (not (miss const_POST))) 
(assert (not (err const_POST)))
 
(declare-const const__dem_app_dem_ (TValue String))
(assert (= (val const__dem_app_dem_) s__dem_app_dem_))
(assert (not (miss const__dem_app_dem_))) 
(assert (not (err const__dem_app_dem_)))
 
(declare-const const__dem_app_dem
			 (TValue String))
(assert (= (val const__dem_app_dem
			) s__dem_app_dem
			))
(assert (not (miss const__dem_app_dem
			))) 
(assert (not (err const__dem_app_dem
			)))
;################################ END ATTRIBUTEs AND CONSTANTs DECLARATION #############################
 
;################### START CONSTRAINT RULE unmask #######################
;##### Rule Target
(define-fun cns_target_unmask () (TValue Bool)
	(equalString n_request/method const_POST)
)
;##### Rule Obligations
(define-fun cns_obl_permit_unmask ()  Bool
	 (and true))
(define-fun cns_obl_deny_unmask ()  Bool true )
;##### Rule Constraints
;PERMIT
(define-fun cns_unmask_permit () Bool
(and (isTrue cns_target_unmask) cns_obl_permit_unmask)
)
;DENY
(define-fun cns_unmask_deny () Bool
 false 
)
;NOT APP
(define-fun cns_unmask_notApp () Bool
	(or (isFalse cns_target_unmask) (miss cns_target_unmask))
)
;INDET
(define-fun cns_unmask_indet () Bool
	(or 
		(not
			(or  
				(isBool cns_target_unmask)
				(miss cns_target_unmask)
			)
		)
		(and 
			(isTrue cns_target_unmask)
			(not cns_obl_permit_unmask)
		)
	)
)
;################### END CONSTRAINT RULE unmask #########################
;################### START CONSTRAINT RULE unmask_passthrough #######################
;##### Rule Target
(define-fun cns_target_unmask_passthrough () (TValue Bool)
	(FAnd (equalString n_response/method const_POST) (equalInt n_response/response - code const_200))
)
;##### Rule Obligations
(define-fun cns_obl_permit_unmask_passthrough ()  Bool
true
)
(define-fun cns_obl_deny_unmask_passthrough ()  Bool true )
;##### Rule Constraints
;PERMIT
(define-fun cns_unmask_passthrough_permit () Bool
(and (isTrue cns_target_unmask_passthrough) cns_obl_permit_unmask_passthrough)
)
;DENY
(define-fun cns_unmask_passthrough_deny () Bool
 false 
)
;NOT APP
(define-fun cns_unmask_passthrough_notApp () Bool
	(or (isFalse cns_target_unmask_passthrough) (miss cns_target_unmask_passthrough))
)
;INDET
(define-fun cns_unmask_passthrough_indet () Bool
	(or 
		(not
			(or  
				(isBool cns_target_unmask_passthrough)
				(miss cns_target_unmask_passthrough)
			)
		)
		(and 
			(isTrue cns_target_unmask_passthrough)
			(not cns_obl_permit_unmask_passthrough)
		)
	)
)
;################### END CONSTRAINT RULE unmask_passthrough #########################
;################################ TOP-LEVEL POLICY dum_proxy CONSTRAINTs ###########################
;##### Policy Target
(define-fun cns_target_dum_proxy () (TValue Bool)
	(FOr (FAnd (equalString n_service/id const_129.27.142.49) (equalString n_request/path const__dem_app_dem
	)) (FAnd (equalString n_service/id const_129.27.142.49) (equalString n_response/path const__dem_app_dem_)))
)
;##### Policy Obligations
(define-fun cns_obl_permit_dum_proxy ()  Bool
true
)
(define-fun cns_obl_deny_dum_proxy ()  Bool
true
)
;##### Policy Combining Algorithm
(define-fun cns_dum_proxy_cmb_final_permit () Bool
	 (or 
		 (and cns_unmask_permit cns_unmask_passthrough_permit)
		 (and cns_unmask_permit cns_unmask_passthrough_notApp)
		 (and cns_unmask_notApp cns_unmask_passthrough_permit)
	 )
)

(define-fun cns_dum_proxy_cmb_final_deny () Bool
	 (or cns_unmask_deny cns_unmask_passthrough_deny)
)

(define-fun cns_dum_proxy_cmb_final_notApp () Bool
	 (and cns_unmask_notApp cns_unmask_passthrough_notApp)
)

(define-fun cns_dum_proxy_cmb_final_indet () Bool
	 (or 
		 (and cns_unmask_indet (not cns_unmask_passthrough_deny))
		 (and (not cns_unmask_deny) cns_unmask_passthrough_indet)
	 )
)

 
;##### Policy Final Constraints
;PERMIT
(define-fun cns_dum_proxy_permit () Bool
	(and 
		(isTrue cns_target_dum_proxy)
		cns_dum_proxy_cmb_final_permit
		cns_obl_permit_dum_proxy
	)
)
;DENY
(define-fun cns_dum_proxy_deny () Bool
	(and 
		(isTrue cns_target_dum_proxy)
		cns_dum_proxy_cmb_final_deny
		cns_obl_deny_dum_proxy
	)
)
;NOT APP
(define-fun cns_dum_proxy_notApp () Bool
	(or
		(or (isFalse cns_target_dum_proxy) (miss cns_target_dum_proxy))
		(and (isTrue cns_target_dum_proxy) cns_dum_proxy_cmb_final_notApp)
	)
)
;INDET
(define-fun cns_dum_proxy_indet () Bool
	(or 
		(not
			(or  
				(isBool cns_target_dum_proxy)
				(miss cns_target_dum_proxy)
			)
		)
		(and (isTrue cns_target_dum_proxy) cns_dum_proxy_cmb_final_indet)
		(and 
			(isTrue cns_target_dum_proxy)
			cns_dum_proxy_cmb_final_permit
			(not cns_obl_permit_dum_proxy)
		)
		(and 
			(isTrue cns_target_dum_proxy)
			cns_dum_proxy_cmb_final_deny
			(not cns_obl_deny_dum_proxy)
		)
	)
)
;################### END TOP-LEVEL POLICY dum_proxy CONSTRAINTs #########################
