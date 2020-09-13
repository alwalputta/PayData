<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" exclude-result-prefixes="xsl pi xsd"
	xmlns:pi="urn:com.workday/picof" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output indent="yes" method="xml" />

	<!--
		The company.id and pay.group.id are extracted by the assembly and
		passed to the transformation as a stylesheet parameters.
	-->
	<xsl:param name="company.id" />
	<xsl:param name="pay.group.id" />


	<xsl:template match="/pi:Employee">

		<!--
			By default, the Workday Employee ID is used to identify the employee
			in the output file. If an alternative type of ID is mapped to the ID
			type 'PAYDATA_ID' in the configuration of the Payroll Interface
			output file integration, then it will be used instead.
		-->
		<xsl:variable name="employeeId">
			<xsl:choose>
				<xsl:when test="pi:Identifier[pi:Identifier_Type = 'PAYDATA_ID']">
					<xsl:value-of
						select="pi:Identifier[pi:Identifier_Type = 'PAYDATA_ID']/pi:Identifier_Value" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="pi:Summary/pi:Employee_ID" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<Payments>
			<xsl:for-each select="pi:Pay_Data">

				<xsl:variable name="isEarning"
					select="xsd:boolean(pi:Earning_or_Deduction = 'E')" />
				<xsl:variable name="code" select="pi:Code" />
				<xsl:variable name="amount" select="pi:Amount" />

				<Payment>
					<Company>
						<xsl:value-of select="$company.id" />
					</Company>
					<Pay_Group>
						<xsl:value-of select="$pay.group.id" />
					</Pay_Group>
					<Employee>
						<xsl:value-of select="$employeeId" />
					</Employee>
					<!--
						In this sample, the earnings and deductions are placed in
						different columns in the output file. The xsl:choose decides which
						column to places the values in.
					-->

					<xsl:choose>
						<xsl:when test="$isEarning">
							<Earning_Code>
								<xsl:value-of select="$code" />
							</Earning_Code>
							<Earning_Amount>
								<xsl:value-of select="$amount" />
							</Earning_Amount>
							<Deduction_Code />
							<Deduction_Amount />
						</xsl:when>
						<xsl:otherwise>
							<Earning_Code />
							<Earning_Amount />
							<Deduction_Code>
								<xsl:value-of select="$code" />
							</Deduction_Code>
							<Deduction_Amount>
								<xsl:value-of select="$amount" />
							</Deduction_Amount>
						</xsl:otherwise>
					</xsl:choose>
				</Payment>

			</xsl:for-each>
		</Payments>

	</xsl:template>

</xsl:stylesheet>