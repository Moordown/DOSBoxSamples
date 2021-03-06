����   �!  �!                       OX    R              �K�    H %��5� �3��1�k s��  ��"�� Ru\<n�-�]��1 Run a query, screen, report, label or application������ alt+N�� ALT+N�� {��  �����  � s��  ��������@ s�����  "�� \<New Query��� Create a new Query���FFx�
��B s�����  "��
 \<Query...��� Run an existing Query���FFx�
��: s�����  "�� \<Screen...��� Run a Screen���FFx�
��: s�����  "�� \<Report...��� Run a Report���FFx�
��8 s�����  "��
 \<Label...��� Run a Label���FFx�
�� s�����  "�� \-���FFx�
��E s�����  "�� \<Application...��� Run an Application���FFx�
�� ���1 s��  ��"�� Ru\<n������ alt+N�� ALT+N�� {��  �����  � s��  ��������( s�����  "�� \<New Query���FFx�
��' s�����  "��
 \<Query...���FFx�
��( s�����  "�� \<Screen...���FFx�
��( s�����  "�� \<Report...���FFx�
��' s�����  "��
 \<Label...���FFx�
�� s�����  "�� \-���FFx�
��- s�����  "�� \<Application...���FFx�
�� �D 1������  �2 DO dorun IN (SYS(2004)+'foxstart.app') WITH "RQBE"�E 1������  �3 DO dorun IN (SYS(2004)+'foxstart.app') WITH "*.QPR"�E 1������  �3 DO dorun IN (SYS(2004)+'foxstart.app') WITH "*.SPR"�E 1������  �3 DO dorun IN (SYS(2004)+'foxstart.app') WITH "*.FRX"�E 1������  �3 DO dorun IN (SYS(2004)+'foxstart.app') WITH "*.LBX"�E 1������  �3 DO dorun IN (SYS(2004)+'foxstart.app') WITH "*.APP"� GY%� U RUN       b 4�  � %�F� TALKz� ON��7 � G2� T�� �� ON�� �Q � T�� �� OFF�� � T��  �FF�  �j�� ��u ��� ���  � RQBE��� �) � ��� MODIFY QUERY untitled NOWAIT�� ���  � *.QPR��/�- T��  �F� QPR� Query To Run:� Run���� ���+� �� UNTITLEDF��  j��F�" � ��� MODIFY QUERY UNTITLED�� �F��  �
� F��  2	��+�6 1�. DO message_win WITH "Could not execute query "� T�� �F� UDFPARMSz�� G^� T�� �F ��  � �� SET UDFPARMS &setudfparms
" � ��� SET DEFAULT TO �� �� � ��� DO ��  �� {�  � � ���  � *.FRX��(�1 T��  �F� FRX� Report To Run:� Run...���� ����$� �� UNTITLEDF��  j����' T�� �F� DBF� Select Database:��� %�F�� �
����: %�FF�� F� \�� ��F�� @F� \�� ��`�
��3� F� � USE  &datafil AGAIN
 �o�4 F�F�� F� \�� ��F�� @F� \�� ��`�� �* � ��� CREATE REPORT UNTITLED NOWAIT�� � �F��  �
� F��  2	��$�3 1�+ DO message_win WITH "Could not run report "� T�� �F� UDFPARMSz�� G^� T�� �F ��  � �� SET UDFPARMS &setudfparms
 G(��� �� T�� ��  �� T�� �F� UDFPARMSz�� G^ �) T�� �F ��  ��  �
 Run Report�	 �� {�  � SET UDFPARMS &setudfparms
 %��� �� � G(��� ��6 � ��� REPORT FORM ��  �  ENVIRONMENT �� �� � � ���  � *.LBX���0 T��  �F� LBX� Label To Run:� Run...���� ��}�� �� UNTITLEDF��  j����' T�� �F� DBF� Select Database:��� %�F�� �
����: %�FF�� F� \�� ��F�� @F� \�� ��`�
��+� F� � USE  &datafil AGAIN
 �g�4 F�F�� F� \�� ��F�� @F� \�� ��`�� �) � ��� CREATE LABEL UNTITLED NOWAIT�� � �F��  �
� F��  2	���2 1�* DO message_win WITH "Could not run label "� T�� �F� UDFPARMSz�� G^� T�� �F ��  � �� SET UDFPARMS &setudfparms
 G(��� �� T�� ��  �� T�� �F� UDFPARMSz�� G^ �( T�� �F ��  ��  �	 Run Label�	 �� SET UDFPARMS &setudfparms
 %��� ��� G(��� ��5 � ��� LABEL FORM ��  �  ENVIRONMENT �� �� � {�  � � ���  � *.SPR��6
�0 T��  �FF� SPR� Screen To Run:� Run��j�� ��q�2
� �� UNTITLED��  ���	�' T�� �F� DBF� Select Database:��� %�F�� �
���	�: %�FF�� F� \�� ��F�� @F� \�� ��`�
��	� F� � USE  &datafil AGAIN
 �Y	�4 F�F�� F� \�� ��F�� @F� \�� ��`�� �* � ��� CREATE SCREEN UNTITLED NOWAIT�� � �F��  �
� F��  2	��2
� T�� �F� UDFPARMSz�� G^� T�� �F ��  � �� SET UDFPARMS &setudfparms
" �
 ��� SET DEFAULT TO �� �� �
 ��� DO ��  �� � ���  � *.APP����= T��  �F� APP; PRG| FXP� Application To Run:� Run���� ���
��� �� UNTITLEDF��  j��Q�3 %�FF��a�
 foxapp.app2� F�
 foxapp.app2���% �
 ��� DO F��a�
 FOXAPP.APP�� �M�8 � ���+ The application generator is not available.�� � �F��  �
� F��  2	���� T�� �F� UDFPARMSz�� G^� T�� �F ��  � �� SET UDFPARMS &setudfparms
" �
 ��� SET DEFAULT TO �� �� �
 ��� DO ��  �� � � %�F�	 _msysmenu����$� GY(� �- %�F�
 m.talkstatf� C� �� � ON	��[� G2 � � U FILNAME   TALKSTAT  MACRO_EXECSETUDFPARMNEWDIR    JUSTPATH  DATAFIL ECOPTIONS  MPRINTOK RMPRINTOPS  KYBD_EXECUMESSAGE_WI�  4�  � 5� T��  �FF��  j��� %�� \��  ��� �! T��  �F��  �F� \��  �`��F %�F��  �U� \� F��  @�	� F��  F��  @��`� :	��� �! T��  �F��  �F��  @�`�� � B���  �� �� �	 B��  �� � U FILNAME   ' 4�  � � � 5� � � T� ���� T� ���� �
 report.spr�� � � %�� ���e � B�/�� � %�� ���� � %�F�a� READY��� � T�  �� TO PRINT OFF�� �� �? � ���2 Printer not ready.  Connect printer and try again.�� B�/�� � �� T�  �� PREVIEW�� � B�e�� U OPTS ME   FILETODO  DLOGTEXT CREPORTOK MTOPRINT   REPORT    SPR FIL ECMESSAGE_WI�  4�  � 5� � %�F� command���- �	 t,�� � �= � t,� � � \�� {ESC}�;� T�� �F��  j�� +�F�� @� ��� � \�F�� ��?�;� T�� �F�� F�� @��U�� � \�� {ENTER}�;� B� U CMD  ME   KEYBD DO  COMMAND  C  4�  � &cmd
 B� U CMD  ME   �  4�  � � 5� � � T� �F�	 MEMOWIDTHz�� G$(��� �� T��  ���  F�� �� T�� �FF�� ��  ��� G$(��� �� B��� �� U MSG  ME   WIDTH DO  SAVE_MW  CRES D D  Mz 4�  � 5� � � � � � � T�� ����' T�� �F�FF��  @��� �I�� T�� �FF��� �:��* T�� ��F ��  �� ��� � �� T�� �FF��� �:��? s,� ��� ���� �(��� �� ���� �� ��������� G]�	 t,�� �0 ���  ��� VFF�� ��� ^����� �� ��FH����� �,� �	 R��  �� u,� � <,� � G] � �� B� U	 MESSAGE   X DTH DO  Y VE_MW  CWIDTH D  MHEIGHT    MARGIN    HELP IL ECNOLINES WIMW GHT  RMDORUN      t  JUSTPATH   R  PRINTOPS   D  KYBD_EXECU �  MACRO_EXEC �  NOLINES    �  MESSAGE_WI z      �              1G�     4�  � � �� ��� ��5��9� ��( 12� f1� HELP � output destinations� 5�� �� �� � %�F� TALKz� ON��� � G2� T�� �� ON�� �� � T�� �� OFF�� � T�� �F�
 COMPATIBLEz�� GA�� %�F� repdial�
� FF� REPDIAL� j� REPDIAL.PJX� FF� REPDIAL� j� REPDIAL.SCX� FF� REPDIAL� j� REPDIAL.MNX� FF� REPDIAL� j� REPDIAL.PRG� FF� REPDIAL� j� REPDIAL.QPR����D s,� �   �    ��l'	 �?U% @�� MS Sans Serif����A�� B�����	 z,� �� � %�F� repdial����	 t,�� � ��	 t,�� � �> �&�  �?�  B������������(�N �?U$ C�������` �   ��� ��F� F� \� ��`�@�� MS Sans Serif����A�� B����      �?�����v���@@��� �b �?� �� ���@�� MS Sans Serif����A�� B����V-�� @���/�$�U%@����t�V@���� @*HT \!\<Run;\?\<Cancel��� ��� ��� �� ���@�� MS Sans Serif����A�� BT����!�rh���?���      (@�����ʡE��?���� @*RVN Pre\<view;To \<Print�� %�F� repdial�
���� t,� � � 9���F�	 ��� <,� � %��� � ON��� G2 � � %��� � ON��0� GA � � �� ��2���� ��( 12� f1� HELP � output destinations� 5�� �� �� � %�F� TALKz� ON���� G2� T�� �� ON�� ��� T�� �� OFF�� � T�� �F�
 COMPATIBLEz�� GA�� %�F� repdial�
� FF� REPDIAL� j� REPDIAL.PJX� FF� REPDIAL� j� REPDIAL.SCX� FF� REPDIAL� j� REPDIAL.MNX� FF� REPDIAL� j� REPDIAL.PRG� FF� REPDIAL� j� REPDIAL.QPR��r�� DEFINE WINDOW repdial  FROM INT((SROW()-10)/2),INT((SCOL()-39)/2)  TO INT((SROW()-10)/2)+9,INT((SCOL()-39)/2)+38  TITLE "&DLOGLAB"  FLOAT  NOCLOSE  NOMINIMIZE  DOUBLE  COLOR SCHEME 5
 � %�F� repdial�����	 t,�� � ���	 t,�� � � �� ��� �(�����$��0 ��������F� F� \� ��`�������!��H �������� ���������
������� @*HT \!\<Run;\?\<Cancel��K �������� ������������ ���� @*RVN Pre\<view;To \<Print�� %�F� repdial�
���� t,� � � 9�� <,� � %��� � ON���� G2 � � %��� � ON���� GA � � �� � U
 DLOGLAB � REPFILE d F1        CURRAREA  TALKSTAT  COMPSTAT  REPDIAL   REPORTOK  TOPRINT   _QBF0J7AZ5  /,�  '�� �� U REPDIAL � DLOGLAB d _QBF0J7AZ5 �  c:\dos\ RUN.FXP REPORT.SPX  *   �          �  �!         