package owltools.reasoner;

import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.reasoner.BufferingMode;
import org.semanticweb.owlapi.reasoner.IllegalConfigurationException;
import org.semanticweb.owlapi.reasoner.OWLReasoner;
import org.semanticweb.owlapi.reasoner.OWLReasonerConfiguration;
import org.semanticweb.owlapi.reasoner.OWLReasonerFactory;
import org.semanticweb.owlapi.reasoner.SimpleConfiguration;

public class GraphReasonerFactory implements OWLReasonerFactory {

    public String getReasonerName() {
        return "Graph Reasoner";
    }

    public OWLReasoner createNonBufferingReasoner(OWLOntology ontology) {
        return createNonBufferingReasoner(ontology, new SimpleConfiguration());
    }

    public OWLReasoner createReasoner(OWLOntology ontology) {
        return createReasoner(ontology, new SimpleConfiguration());
    }

    public OWLReasoner createNonBufferingReasoner(OWLOntology ontology, OWLReasonerConfiguration config) throws IllegalConfigurationException {
        return new GraphReasoner(ontology, config, BufferingMode.NON_BUFFERING);
    }

    public OWLReasoner createReasoner(OWLOntology ontology, OWLReasonerConfiguration config) throws IllegalConfigurationException {
        return new GraphReasoner(ontology, config, BufferingMode.BUFFERING);
    }
}
