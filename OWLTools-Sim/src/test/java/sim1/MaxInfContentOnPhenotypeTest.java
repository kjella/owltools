package sim1;

import org.junit.Test;
import org.semanticweb.owlapi.model.OWLObject;

import owltools.graph.OWLGraphWrapper;
import owltools.sim.MaximumInformationContentSimilarity;
import owltools.sim.Similarity;

public class MaxInfContentOnPhenotypeTest extends AbstractSimEngineTest {

	@Test
	public void testOrganismPair() throws Exception{
		OWLGraphWrapper  wrapper =  getOntologyWrapper("lcstest3.owl");
		Similarity sa = 
			new MaximumInformationContentSimilarity();
		OWLObject a = wrapper.getOWLObjectByIdentifier("http://example.org#o1");
		OWLObject b = wrapper.getOWLObjectByIdentifier("http://example.org#o2");
		run(wrapper,sa,a,b);
	}	
	
}
